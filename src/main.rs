use clap::Parser;
use std::error::Error;
use std::fs;
use std::fs::File;
use std::io;
use std::io::BufRead;
use std::io::BufReader;
use std::io::Write;
use std::process::Command;
use tempfile::NamedTempFile;

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
}

fn main() -> Result<(), Box<dyn Error>> {
    let args = CliArgs::parse();

    let blanks = |line: &String| !line.trim().is_empty();
    let cmds: Vec<String> = if args.file == "-" {
        io::stdin()
            .lock()
            .lines()
            .filter_map(|res| res.ok())
            .filter(blanks)
            .collect()
    } else {
        let file = File::open(args.file)?;
        BufReader::new(file)
            .lines()
            .filter_map(|res| res.ok())
            .filter(blanks)
            .collect()
    };
    if cmds.is_empty() {
        return Err("no commands given".into());
    }

    let mut targets = Vec::with_capacity(cmds.len());
    for cmd in cmds {
        match shlex::split(&cmd) {
            None => return Err(format!("typo in {:?}", cmd).into()),
            Some(words) => {
                let parsed = DockerBuildArgs::try_parse_from(words).map_err(|e| {
                    eprintln!("Could not parse {:?}", cmd);
                    e.exit() // NOTE: fn exit() -> !
                });
                if let Ok(build_args) = parsed {
                    targets.push(build_args);
                }
            }
        }
    }

    let mut command = Command::new("docker");
    command.env("DOCKER_BUILDKIT", "1");
    command.arg("buildx");
    command.arg("bake");
    command.arg("--progress").arg(args.progress);
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
    writeln!(f, "group {:?} {{ targets = [", "default")?;
    for i in 1..(targets.len() + 1) {
        writeln!(f, "\"{}\",", i)?;
    }
    writeln!(f, "]}}")?;
    for (i, target) in targets.iter().enumerate() {
        let DockerBuild::Build(target) = &target.build;
        writeln!(f, "target \"{}\" {{", 1 + i)?;

        if !target.build_args.is_empty() {
            writeln!(f, "args = {{")?;
            for arg in &target.build_args {
                match arg.split_once('=') {
                    Some((key, value)) => writeln!(f, "{:?} = {:?}", key, value)?,
                    None => return Err(format!("bad key=value: {:?}", arg).into()),
                }
            }
            writeln!(f, "}}")?;
        }

        if let Some(cache_from) = &target.cache_from {
            writeln!(f, "cache-from = [{:?}]", cache_from)?;
        }

        if let Some(cache_to) = &target.cache_to {
            // TODO
            eprintln!("Ignoring --cache-to {:?}", cache_to);
            // error: cache export feature is currently not supported for docker driver
            // cache-to = ["type=registry,ref=ghcr.io/user/repo:binaries,mode=max"]
            // writeln!(f, "cache-to = [{:?}]", cache_to)?;
        }

        writeln!(f, "context = {:?}", &target.path_or_url)?;

        if let Some(build_context) = &target.build_context {
            writeln!(f, "contexts = [{:?}]", build_context)?;
        }

        if let Some(file) = &target.file {
            writeln!(f, "dockerfile = {:?}", file)?;
        }

        if let Some(label) = &target.label {
            writeln!(f, "labels = [{:?}]", label)?;
        }

        if target.no_cache {
            writeln!(f, "no-cache = true")?;
        }

        if let Some(no_cache_filter) = &target.no_cache_filter {
            writeln!(f, "no-cache-filter = [{:?}]", no_cache_filter)?;
        }

        if let Some(output) = &target.output {
            writeln!(f, "output = [{:?}]", output)?;
        }

        if let Some(platform) = &target.platform {
            writeln!(f, "platforms = [{:?}]", platform)?;
        }

        if target.pull {
            writeln!(f, "pull = true")?;
        }

        if let Some(secret) = &target.secret {
            writeln!(f, "secrets = [{:?}]", secret)?;
        }

        if let Some(ssh) = &target.ssh {
            writeln!(f, "ssh = [{:?}]", ssh)?;
        }

        if let Some(tag) = &target.tag {
            writeln!(f, "tags = [{:?}]", tag)?;
        }

        if let Some(target) = &target.target {
            writeln!(f, "target = [{:?}]", target)?;
        }

        writeln!(f, "}}")?;
    }
    f.flush()?;
    if args.debug {
        let data = fs::read_to_string(f.path())?;
        eprintln!("{}", data);
    }
    // TODO: pass data through BufWriter to STDIN with `-f-`
    command.arg("-f");
    command.arg(f.path());

    let status = command.status()?;
    let prefix = "command `docker buildx bake`";
    match status.code() {
        Some(0) => Ok(()),
        Some(code) => Err(format!("{} failed with {}", prefix, code).into()),
        None => Err(format!("{} terminated by signal", prefix).into()),
    }
}

#[derive(Parser, Debug)]
#[clap(name="docker", about = "Start a build", long_about=None)]
// DockerBuildArgs correspond to `DOCKER_BUILDKIT=1 docker build --help`
struct DockerBuildArgs {
    #[clap(subcommand)]
    build: DockerBuild,
}

#[derive(clap::Subcommand, Debug)]
enum DockerBuild {
    Build(BuildArgs),
}

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
#[derive(clap::Args, Debug)]
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
