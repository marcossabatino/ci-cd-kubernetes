import express from 'express';
import { logger } from '../middleware/logger.js';

const router = express.Router();

export function createAgentRoutes(orchestrator) {
  router.get('/', (req, res) => {
    try {
      const agents = orchestrator.getAvailableAgents();
      logger.info({ count: agents.length }, 'Listed available agents');
      res.json({
        success: true,
        data: agents,
        count: agents.length
      });
    } catch (error) {
      logger.error({ error: error.message }, 'Failed to list agents');
      res.status(500).json({ success: false, error: error.message });
    }
  });

  router.post('/:agentId/message', async (req, res) => {
    try {
      const { agentId } = req.params;
      const { message, context = [] } = req.body;

      if (!message || message.trim() === '') {
        return res.status(400).json({
          success: false,
          error: 'Message is required'
        });
      }

      const agent = orchestrator.agents.get(agentId);
      if (!agent) {
        return res.status(404).json({
          success: false,
          error: `Agent '${agentId}' not found`
        });
      }

      logger.info({
        agent: agentId,
        messageLength: message.length,
        contextLength: context.length
      }, 'Processing message');

      const response = await agent.process(message, context);

      logger.info({
        agent: agentId,
        responseTime: Date.now()
      }, 'Message processed');

      res.json({
        success: true,
        data: response
      });
    } catch (error) {
      logger.error({ error: error.message, agentId: req.params.agentId }, 'Failed to process message');
      res.status(500).json({ success: false, error: error.message });
    }
  });

  return router;
}

export default router;
