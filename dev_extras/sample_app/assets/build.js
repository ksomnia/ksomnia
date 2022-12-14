const esbuild = require('esbuild')
const util = require('util')
const exec = util.promisify(require('child_process').exec)

const args = process.argv.slice(2)
const watch = args.includes('--watch')
const deploy = args.includes('--deploy')

const getCommitHash = async () => {
  const { stdout, stderr } = await exec('git show-ref --head --hash head');
  return stdout.trim()
}

const main = async () => {
  console.log(`Compiling for ${await getCommitHash()} (${deploy && '[deploy]'})`)

  let opts = {
    entryPoints: ['js/app.js'],
    bundle: true,
    target: 'es2017',
    external: ['/fonts/*', '/images/*'],
    outdir: '../priv/static/assets',
    logLevel: 'info',
    define: {
      'process.env.COMMIT_HASH': JSON.stringify(await getCommitHash()),
      'process.env.KSOMNIA_BASE_URL': JSON.stringify(process.env.KSOMNIA_BASE_URL) || JSON.stringify('http://localhost:4000/tracker_api/v1')
    },
    minify: true,
    sourcemap: 'external'
  }

  if (watch) {
    opts = {
      ...opts,
      watch,
    }
  }

  if (deploy) {
    opts = {
      ...opts,
      minify: true,
    }
  }

  const promise = esbuild.build(opts).catch(() => process.exit(1))

  if (watch) {
    promise.then(_result => {
      process.stdin.on('close', () => {
        process.exit(0)
      })

      process.stdin.resume()
    })
  }
}

main()
