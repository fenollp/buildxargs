use buildxargs::try_quick;
use clap::Parser;
use std::fs::File;
use std::io::{stderr, stdin, BufRead, BufReader, Write};
use std::process::{Command, ExitStatus};
use tempfile::NamedTempFile;

type Res<T> = std::result::Result<T, Box<dyn std::error::Error + Send + Sync + 'static>>;

#[derive(Parser, Debug)]
#[clap(author, version, about, long_about=None)]
// CliArgs correspond to `docker buildx bake --help`
struct CliArgs {
    /// Read commands from file.
    #[clap(short, long="file", default_value_t=String::from("-"))]
    file: String,

    /// Do not use cache when building the image
    #[clap(long = "no-cache")]
    no_cache: bool,

    /// Print the options without building
    #[clap(long = "print")]
    print: bool,

    /// Set type of progress output ("plain", "tty")
    #[clap(long="progress", default_value_t=String::from("auto"))]
    progress: String,

    /// Always attempt to pull all referenced images
    #[clap(long = "pull")]
    pull: bool,

    /// Print more things
    #[clap(long = "debug")]
    debug: bool,

    /// Retry each failed build at most this many times
    #[clap(long = "retry", default_value_t = 3u8)]
    retry: u8,
}

fn main() -> Res<()> {
    let args = CliArgs::parse();

    let blanks = |line: &String| !line.trim().is_empty();
    let cmds: Vec<String> = if args.file == "-" {
        stdin()
            .lock()
            .lines()
            .map_while(Result::ok)
            .filter(blanks)
            .collect()
    } else {
        let file = File::open(&args.file)?;
        BufReader::new(file)
            .lines()
            .map_while(Result::ok)
            .filter(blanks)
            .collect()
    };
    if cmds.is_empty() {
        return Err("no commands given".into());
    }

    // Parse here to fail early
    let targets = parse_shell_commands(&cmds)?;

    if args.debug {
        let mut stderr = stderr().lock();
        write_as_bake(&mut stderr, &targets)?;
    }

    let ixs_failed = try_quick(
        &targets,
        args.retry,
        |targets: &[DockerBuildArgs]| -> Res<()> {
            let prefix = "command `docker buildx bake`";
            let status = run_bake(&args, targets)?;
            match status.code() {
                None => Err(format!("{prefix} terminated by signal").into()),
                Some(0) => Ok(()),
                Some(code) => Err(format!("{prefix} failed with {code}").into()),
            }
        },
    )?;

    if !ixs_failed.is_empty() {
        let mut printed = false;
        for (ix, cmd) in cmds.iter().enumerate() {
            if !ixs_failed.contains_key(&ix) {
                if !printed {
                    printed = true;
                    eprintln!("Terminated successfully:");
                }
                eprintln!("  {}", cmd);
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
        let m = args.retry;
        return Err(format!("{n} jobs failed after {m} retries",).into());
    }

    Ok(())
}

fn run_bake(args: &CliArgs, targets: &[DockerBuildArgs]) -> Res<ExitStatus> {
    let mut command = Command::new("docker");
    command.env("DOCKER_BUILDKIT", "1");
    command.arg("buildx");
    command.arg("bake");
    command.arg("--progress").arg(&args.progress);
    if args.no_cache {
        command.arg("--no-cache");
    }
    if args.print {
        command.arg("--print");
    }
    if args.pull {
        command.arg("--pull");
    }

    let mut f = NamedTempFile::new()?;
    write_as_bake(&mut f, targets)?;
    f.flush()?;
    // TODO: pass data through BufWriter to STDIN with `-f-`
    command.arg("-f");
    command.arg(f.path());

    Ok(command.status()?)
}

fn parse_shell_commands(cmds: &[String]) -> Res<Vec<DockerBuildArgs>> {
    let mut targets = Vec::with_capacity(cmds.len());
    for cmd in cmds {
        match shlex::split(cmd) {
            None => return Err(format!("Typo in {cmd}").into()),
            Some(words) => {
                let parsed = DockerBuildArgs::try_parse_from(words).map_err(|e| {
                    eprintln!("Could not parse {cmd}"); //fixme:drop exit and use ?
                    e.exit() // NOTE: fn exit() -> !
                });
                if let Ok(build_args) = parsed {
                    targets.push(build_args);
                }
            }
        }
    }
    Ok(targets)
}

fn write_as_buildx_bake(f: &mut impl Write, targets: &[DockerBuildArgs]) -> Res<()> {
    writeln!(f, "group \"default\" {{\n  targets = [")?;
    for i in 1..=targets.len() {
        writeln!(f, "    \"{i}\",")?;
    }
    writeln!(f, "  ]\n}}")?;
    for (i, target) in targets.iter().enumerate() {
        let (i, DockerBuild::Build(target)) = (i + 1, &target.build);
        writeln!(f, "target \"{i}\" {{")?;

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

#[derive(Parser, Debug, Clone)]
#[clap(name="docker", about = "Start a build", long_about=None)]
// DockerBuildArgs correspond to `DOCKER_BUILDKIT=1 docker build --help`
struct DockerBuildArgs {
    #[clap(subcommand)]
    build: DockerBuild,
}

#[derive(clap::Subcommand, Debug, Clone)]
enum DockerBuild {
    Build(BuildArgs),
}

// https://github.com/docker/docs/blob/main/build/bake/file-definition.md
// Complete list of valid target fields from https://docs.docker.com/engine/reference/commandline/buildx_bake
// args
// cache-from
// cache-to
// context
// contexts
// dockerfile
// inherits
// labels
// no-cache
// no-cache-filter
// output
// platforms
// pull
// secrets
// ssh
// tags
// target
#[derive(clap::Args, Debug, Clone)]
struct BuildArgs {
    path_or_url: String, // context

    /// Set build-time variables
    #[clap(long = "build-arg")]
    build_args: Vec<String>, // args

    /// Additional build contexts (e.g., name=path)
    #[clap(long = "build-context")]
    build_context: Option<String>, // contexts (TODO: stringArray)

    /// External cache sources
    #[clap(long = "cache-from")]
    cache_from: Option<String>, // cache-from (TODO: stringArray)

    /// Cache export destinations
    #[clap(long = "cache-to")]
    cache_to: Option<String>, // cache-to (TODO: stringArray)

    /// Name of the Dockerfile
    #[clap(short, long = "file")]
    file: Option<String>, // dockerfile

    /// Set metadata for an image
    #[clap(long = "label")]
    label: Option<String>, // labels (TODO: stringArray)

    // FIXME: https://docs.rs/clap/latest/clap/enum.ArgAction.html#variant.Append
    /// Set the networking mode for the "RUN" instructions during build (default "default")
    #[clap(long = "network", action(clap::ArgAction::Append))]
    network: Option<String>,

    /// Do not use cache when building the image
    #[clap(long = "no-cache")]
    no_cache: bool, // no-cache

    /// Do not cache specified stages
    #[clap(long = "no-cache-filter")]
    no_cache_filter: Option<String>, // no-cache-filter (TODO: stringArray)

    /// Output destination (format: "type=local,dest=path")
    #[clap(short, long = "output")]
    output: Option<String>, // output (TODO: stringArray)

    /// Set target platform for build
    #[clap(long = "platform")]
    platform: Option<String>, // platforms (TODO: stringArray)

    /// Always attempt to pull all referenced images
    #[clap(long = "pull")]
    pull: bool, // pull

    /// Secret to expose to the build (format: "id=mysecret[,src=/local/secret]")
    #[clap(long = "push")]
    secret: Option<String>, // secrets (TOOD: stringArray)

    /// SSH agent socket or keys to expose to the build (format: "default|<id>[=<socket>|<key>[,<key>]]")
    #[clap(long = "ssh")]
    ssh: Option<String>, // ssh (TODO: stringArray)

    /// Name and optionally a tag (format: "name:tag")
    #[clap(short, long = "tag")]
    tag: Option<String>, // tags (TODO: stringArray)

    /// Set the target build stage to build
    #[clap(long = "target")]
    target: Option<String>, // target
}
