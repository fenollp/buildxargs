use std::{
    io::{stderr, stdin, BufRead, Write},
    process::{exit, Command, ExitStatus, Output, Stdio},
    thread::spawn,
};

use buildxargs::try_quick;
use pico_args::Arguments;

type Res<T> = std::result::Result<T, Box<dyn std::error::Error + Send + Sync + 'static>>;

fn main() -> Res<()> {
    let mut args = Arguments::from_env();

    if args.contains("--help") {
        return help();
    }
    if args.contains(["-V", "--version"]) {
        return version();
    }

    let cmds: Vec<_> = stdin()
        .lock()
        .lines()
        .map_while(Result::ok)
        .filter(|line| !line.trim().is_empty())
        .collect();
    if cmds.is_empty() {
        return Err("no `docker build` commands given on STDIN".into());
    }

    // Parse here to fail early
    let targets = parse_shell_commands(&cmds)?;

    if args.contains(["-D", "--debug"]) {
        let mut stderr = stderr().lock();
        write_as_buildx_bake(&mut stderr, &targets)?;
    }

    let retry = args.opt_value_from_str("--retry")?.unwrap_or(3);
    let ixs_failed = try_quick(&targets, retry, |targets: &[Build]| -> Res<()> {
        let prefix = "command `docker buildx bake`";
        let status = run_bake(args.clone(), targets)?;
        match status.code() {
            None => Err(format!("{prefix} terminated by signal").into()),
            Some(0) => Ok(()),
            Some(code) => Err(format!("{prefix} failed with {code}").into()),
        }
    })?;

    if !ixs_failed.is_empty() {
        let mut printed = false;
        for (ix, cmd) in cmds.iter().enumerate() {
            if !ixs_failed.contains_key(&ix) {
                if !printed {
                    printed = true;
                    eprintln!("Terminated successfully:");
                }
                eprintln!("  {cmd}");
            }
        }

        eprintln!("Failed:");
        let mut ixs = ixs_failed.keys().copied().collect::<Vec<_>>();
        ixs.sort();
        for ix in ixs {
            if let Some(err) = ixs_failed.get(&ix) {
                eprintln!("  {}\n    {err}", &cmds[ix]);
            } else {
                unreachable!();
            }
        }
        let n = ixs_failed.len();
        return Err(format!("{n} jobs failed after {retry} retries").into());
    }

    Ok(())
}

fn run_bake(args: Arguments, targets: &[Build]) -> Res<ExitStatus> {
    let mut command = Command::new("docker");
    command.env("DOCKER_BUILDKIT", "1");
    command.arg("buildx");
    command.arg("bake");

    for allow in entitlements(targets) {
        command.args(["--allow", &allow]);
    }

    command.arg("-f-").stdin(Stdio::piped()).stdout(Stdio::inherit()).stderr(Stdio::inherit());

    command.args(args.finish());

    let mut child = command.spawn().expect("Failed to spawn `docker buildx bake` process");

    let mut stdin = child.stdin.take().expect("Failed to open STDIN");
    let targets = targets.to_vec();
    spawn(move || {
        write_as_buildx_bake(&mut stdin, &targets).expect("Failed to write to STDIN");
    });

    Ok(child.wait()?)
}

#[expect(clippy::needless_return)]
fn help() -> Res<()> {
    let mut command = Command::new("docker");
    command.args(["buildx", "bake", "--help"]);
    let Output { stderr, stdout, status } = command.output()?;
    if !status.success() {
        eprintln!("{}", String::from_utf8_lossy(&stderr));
        exit(1);
    }
    println!("{}", String::from_utf8_lossy(&stdout));

    println!(
        r#"--

xargs for BuildKit with docker buildx bake

Usage: {app} [BAKE OPTIONS] [OPTIONS]

Options:
      --retry <RETRY>        Retry each failed build at most this many times [default: 3]
      --help                 Print help
  -V, --version              Print version

Try:
  {app} <<EOF
docker build --platform=local -o . https://github.com/docker/buildx.git
docker build --tag my-image:latest https://github.com/bojand/ghz.git
EOF

Note that all environment variables (such as $DOCKER_HOST) are passed through to `bake`.
"#,
        app = env!("CARGO_PKG_NAME")
    );
    return Ok(());
}

#[expect(clippy::needless_return)]
#[expect(clippy::unnecessary_wraps)]
fn version() -> Res<()> {
    println!(
        "{} v{} -- {}",
        env!("CARGO_PKG_NAME"),
        env!("CARGO_PKG_VERSION"),
        env!("CARGO_PKG_AUTHORS")
    );
    return Ok(());
}

fn parse_shell_commands(cmds: &[String]) -> Res<Vec<Build>> {
    let mut targets = Vec::with_capacity(cmds.len());
    for cmd in cmds {
        let Some(shlexd) = shlex::split(cmd) else { return Err(format!("typo in {cmd}").into()) };

        #[expect(clippy::if_same_then_else)]
        let skip = if shlexd.contains(&"-D".to_owned()) || shlexd.contains(&"--debug".to_owned()) {
            return Err("Unsupported `docker --debug`".into());
        } else if shlexd[..=1] == ["docker", "build"] {
            2
        } else if shlexd[..=2] == ["docker", "builder", "build"] {
            3
        } else if shlexd[..=2] == ["docker", "buildx", "b"] {
            3
        } else if shlexd[..=2] == ["docker", "buildx", "build"] {
            3
        } else if shlexd[..=2] == ["docker", "image", "build"] {
            3
        } else {
            return Err(format!("not a `docker build` command: {cmd}").into());
        };

        let shlexd = shlexd.iter().skip(skip).map(|x| &**x).map(Into::into).collect();
        let mut argz = Arguments::from_vec(shlexd);

        let mut x = Build {
            path_or_url: String::new(),
            allow: argz.values_from_str("--allow")?,
            build_args: argz.values_from_str("--build-arg")?,
            build_context: argz.values_from_str("--build-context")?.first().cloned(), //FIXME
            cache_from: argz.values_from_str("--cache-from")?.first().cloned(),       //FIXME
            cache_to: argz.values_from_str("--cache-to")?.first().cloned(),           //FIXME
            file: argz.opt_value_from_str(["-f", "--file"])?,
            label: argz.values_from_str("--label")?.first().cloned(), //FIXME
            network: argz.opt_value_from_str("--network")?,
            no_cache: argz.contains("--no-cache"),
            no_cache_filter: argz.values_from_str("--no-cache-filter")?.first().cloned(), //FIXME
            output: argz.values_from_str(["-o", "--output"])?.first().cloned(),           //FIXME
            platform: argz.opt_value_from_str("--platform")?,
            pull: argz.contains("--pull"),
            secret: argz.values_from_str("--secret")?.first().cloned(), //FIXME
            ssh: argz.values_from_str("--ssh")?.first().cloned(),       //FIXME
            tag: argz.values_from_str(["-t", "--tag"])?.first().cloned(), //FIXME
            target: argz.opt_value_from_str("--target")?,
        };

        let leftovers = argz.finish();
        // Let's assume users put this free-form arg last
        x.path_or_url = leftovers.last().cloned().unwrap_or_default().to_string_lossy().to_string();

        targets.push(x);
    }

    Ok(targets)
}

// Turns entitlements & guess some more so they can be passed to `bake`
fn entitlements(targets: &[Build]) -> Vec<String> {
    let mut entitlements: Vec<_> = targets
        .iter()
        .flat_map(|Build { allow, file, output, .. }| {
            allow
                .iter()
                .cloned()
                // https://docs.docker.com/reference/cli/docker/buildx/bake/#allow
                .chain(file.iter().filter(|f| f != &"-").map(|f| format!("fs.read={f}")))
                .chain(
                    output
                        .iter()
                        .filter(|o| o != &"-" && !o.contains("dest=-"))
                        .filter(|o| {
                            !o.contains("type=oci")
                                && !o.contains("type=docker")
                                && !o.contains("type=image")
                                && !o.contains("type=registry")
                        })
                        .filter(|o| !o.contains("type="))
                        .map(|o| format!("fs.write={o}")),
                )
        })
        .collect();

    entitlements.sort();
    entitlements.dedup();

    entitlements
}

fn write_as_buildx_bake(f: &mut impl Write, targets: &[Build]) -> Res<()> {
    writeln!(f, "group \"default\" {{\n  targets = [")?;
    for i in 1..=targets.len() {
        writeln!(f, "    \"{i}\",")?;
    }
    writeln!(f, "  ]\n}}")?;
    for (i, target) in targets.iter().enumerate() {
        writeln!(f, "target \"{}\" {{", i + 1)?;

        // TODO: https://github.com/docker/buildx/issues/179
        // https://github.com/docker/buildx/blob/ada44e82eaed1d0f1a8c43ecd4116aefef2ef2a8/docs/bake-reference.md#targetentitlements
        // if !target.allow.is_empty() {
        //     writeln!(f, "  entitlements = {:?}", target.allow)?;
        // }

        if !target.build_args.is_empty() {
            writeln!(f, "  args = {{")?;
            for arg in &target.build_args {
                match arg.split_once('=') {
                    Some((key, value)) => writeln!(f, "    {key:?} = {value:?}")?,
                    None => return Err(format!("bad key=value: {arg:?}").into()),
                }
            }
            writeln!(f, "  }}")?;
        }

        if let Some(cache_from) = &target.cache_from {
            writeln!(f, "  cache-from = [{cache_from:?}]")?;
        }

        if let Some(cache_to) = &target.cache_to {
            writeln!(f, "  cache-to = [{cache_to:?}]")?;
        }

        let context = &target.path_or_url;
        writeln!(f, "  context = {context:?}")?;

        if let Some(build_context) = &target.build_context {
            writeln!(f, "  contexts = [{build_context:?}]")?;
        }

        if let Some(file) = &target.file {
            writeln!(f, "  dockerfile = {file:?}")?;
        }

        if let Some(label) = &target.label {
            writeln!(f, "  labels = [{label:?}]")?;
        }

        if let Some(network) = &target.network {
            writeln!(f, "  network = {network:?}")?;
        }

        if target.no_cache {
            writeln!(f, "  no-cache = true")?;
        }

        if let Some(no_cache_filter) = &target.no_cache_filter {
            writeln!(f, "  no-cache-filter = [{no_cache_filter:?}]")?;
        }

        if let Some(output) = &target.output {
            writeln!(f, "  output = [{output:?}]")?;
        }

        if let Some(platform) = &target.platform {
            writeln!(f, "  platforms = [{platform:?}]")?;
        }

        if target.pull {
            writeln!(f, "  pull = true")?;
        }

        if let Some(secret) = &target.secret {
            writeln!(f, "  secrets = [{secret:?}]")?;
        }

        if let Some(ssh) = &target.ssh {
            writeln!(f, "  ssh = [{ssh:?}]")?;
        }

        if let Some(tag) = &target.tag {
            writeln!(f, "  tags = [{tag:?}]")?;
        }

        if let Some(target) = &target.target {
            writeln!(f, "  target = [{target:?}]")?;
        }

        writeln!(f, "}}")?;
    }
    Ok(())
}

// https://github.com/docker/buildx/blob/master/docs/bake-reference.md#target
// Complete list of valid target fields from https://docs.docker.com/engine/reference/commandline/buildx_bake
//  args
//  cache-from
//  cache-to
//  context
//  contexts
//  dockerfile
//  inherits
//  labels
//  no-cache
//  no-cache-filter
//  output
//  platforms
//  pull
//  secrets
//  ssh
//  tags
//  target
#[derive(Debug, Clone)]
struct Build {
    path_or_url: String,
    allow: Vec<String>,
    build_args: Vec<String>,
    build_context: Option<String>,
    cache_from: Option<String>,
    cache_to: Option<String>,
    file: Option<String>,
    label: Option<String>,
    network: Option<String>,
    no_cache: bool,
    no_cache_filter: Option<String>,
    output: Option<String>,
    platform: Option<String>,
    pull: bool,
    secret: Option<String>,
    ssh: Option<String>,
    tag: Option<String>,
    target: Option<String>,
}
