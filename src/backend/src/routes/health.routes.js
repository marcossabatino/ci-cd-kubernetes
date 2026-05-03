import express from 'express';
import { logger } from '../middleware/logger.js';

const router = express.Router();

export function createHealthRoutes(healthAgent) {
  router.get('/live', (req, res) => {
    try {
      res.status(200).json({
        status: 'alive',
        timestamp: new Date().toISOString()
      });
    } catch (error) {
      logger.error({ error: error.message }, 'Liveness check failed');
      res.status(503).json({ status: 'unavailable' });
    }
  });

  router.get('/ready', async (req, res) => {
    try {
      const metrics = healthAgent.getHealthMetrics();
      res.status(200).json({
        status: 'ready',
        metrics,
        timestamp: new Date().toISOString()
      });
    } catch (error) {
      logger.error({ error: error.message }, 'Readiness check failed');
      res.status(503).json({ status: 'not_ready' });
    }
  });

  return router;
}

export default router;
