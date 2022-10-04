const esbuild = require('esbuild')
const util = require('util')
const exec = util.promisify(require('child_process').exec)

const args = process.argv.slice(2)
const watch = args.includes('--watch')
const deploy = args.includes('--deploy')

const main = async () => {
  let opts = {
    entryPoints: ['js/app.js'],
    bundle: true,
    target: 'es2017',
    external: ['/fonts/*', '/images/*'],
    outdir: '../priv/static/assets',
    logLevel: 'info'
  }

  if (watch) {
    opts = {
      ...opts,
      watch,
      sourcemap: 'inline'
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
