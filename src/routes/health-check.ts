import type { FastifyInstance } from "fastify";

export async function healthCheckRoute(app: FastifyInstance) {
  app.get('/health-check', async (_, reply) => {
    return reply.status(200).send({ message: 'OK no ECS' })
  })
}