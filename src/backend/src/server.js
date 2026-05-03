import express from 'express';
import cors from 'cors';
import helmet from 'helmet';
import pinoHttp from 'pino-http';
import { logger } from './middleware/logger.js';
import { createAgentRoutes } from './routes/agents.routes.js';
import { createHealthRoutes } from './routes/health.routes.js';
import { createMetricsRoutes } from './routes/metrics.routes.js';
import OrchestratorAgent from './agents/orchestrator.agent.js';
import KubernetesAgent from './agents/kubernetes.agent.js';
import TerraformAgent from './agents/terraform.agent.js';
import HealthAgent from './agents/health.agent.js';

const app = express();
const PORT = process.env.PORT || 3001;

// Middleware de segurança
app.use(helmet());

// CORS
app.use(cors({
  origin: process.env.FRONTEND_URL || 'http://localhost:3000',
  methods: ['GET', 'POST', 'OPTIONS'],
  allowedHeaders: ['Content-Type']
}));

// Parsing
app.use(express.json());

// Logging
app.use(pinoHttp({ logger }));

// Inicializar agentes
const healthAgent = new HealthAgent();
const orchestrator = new OrchestratorAgent();

const kubernetesAgent = new KubernetesAgent();
const terraformAgent = new TerraformAgent();

orchestrator.registerAgent(orchestrator);
orchestrator.registerAgent(kubernetesAgent);
orchestrator.registerAgent(terraformAgent);
orchestrator.registerAgent(healthAgent);

// Rotas
app.use('/api/agents', createAgentRoutes(orchestrator));
app.use('/health', createHealthRoutes(healthAgent));
app.use('/metrics', createMetricsRoutes());

// Root endpoint
app.get('/', (req, res) => {
  res.json({
    service: 'DevOps Agent Orchestrator Backend',
    version: '1.0.0',
    status: 'running',
    endpoints: {
      agents: '/api/agents',
      health: '/health/live',
      ready: '/health/ready',
      metrics: '/metrics'
    }
  });
});

// Error handler global
app.use((err, req, res, next) => {
  logger.error({ err, path: req.path }, 'Unhandled error');
  res.status(500).json({
    success: false,
    error: 'Internal server error',
    message: process.env.NODE_ENV === 'development' ? err.message : undefined
  });
});

// 404 handler
app.use((req, res) => {
  res.status(404).json({
    success: false,
    error: 'Not found',
    path: req.path
  });
});

app.listen(PORT, () => {
  logger.info(
    { port: PORT, env: process.env.NODE_ENV || 'development' },
    'Server started'
  );
});

export default app;
