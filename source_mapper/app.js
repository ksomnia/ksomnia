import { SourceMapConsumer } from 'source-map'
import fastifyLib from 'fastify'
import fs from 'fs/promises'

const fastify = fastifyLib({
  logger: true
})

const getSourceMap = async (filePath) => {
  const content = await fs.readFile(filePath)
  return JSON.parse(content.toString())
}

const extractPosition = (error) => {
  return doExtractPosition(/\(.*\:(\d+)\:(\d+)\)$/, error) ||
    doExtractPosition(/\:(\d+)\:(\d+)$/, error)
}

const doExtractPosition = (regex, error) => {
  const position = regex.exec(error)

  if (Array.isArray(position) && position[1] && position[2]) {
    let line = position[1]
    let col = position[2]

    if (line && col) {
      return [parseInt(line, 10), parseInt(col, 10)]
    }
  }
}

fastify.post('/map_stacktrace', async (request, reply) => {
  let stack = request.body.stack
  let filePath = request.body.file_path
  let sourceMap = await getSourceMap(filePath)

  let mapping = []
  let mappedStacktrace = []
  let sources = {}

  await SourceMapConsumer.with(sourceMap, null, consumer => {
    stack.split('\n').forEach(line => {
      line = line.trim()
      let pos = extractPosition(line)
      if (pos) {
        let mappedPos = consumer.originalPositionFor({
          line: pos[0],
          column: pos[1]
        })

        if (mappedPos.source) {
          let content = consumer.sourceContentFor(mappedPos.source)

          if (content) {
            sources[mappedPos.source] = content
          }
        }

        let mappedLine = `${mappedPos.source}:${mappedPos.line}:${mappedPos.column} ${consumer.sourceContentFor(mappedPos.source).split('\n')[mappedPos.line - 1]}`
        mappedStacktrace.push(mappedLine)
        mappedPos.formattedLine = `${consumer.sourceContentFor(mappedPos.source).split('\n')[mappedPos.line - 1]}`
        mapping.push(mappedPos)
      }
    })
  })

  console.log(mapping)

  return { mapping, mapped_stacktrace: mappedStacktrace.join('\n'), sources }
})

const start = async () => {
  try {
    await fastify.listen({ port: 3000 })
  } catch (err) {
    fastify.log.error(err)
    process.exit(1)
  }
}

start()
