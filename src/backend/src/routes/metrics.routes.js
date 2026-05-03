import express from 'express';

const router = express.Router();

const metrics = {
  http_requests_total: 0,
  http_request_duration_seconds: [],
  agents_messages_processed: 0
};

export function createMetricsRoutes() {
  router.get('/', (req, res) => {
    const memUsage = process.memoryUsage();
    const uptime = process.uptime();

    const prometheusMetrics = `# HELP http_requests_total Total HTTP requests
# TYPE http_requests_total counter
http_requests_total{method="POST",path="/api/agents/*/message",status="200"} ${metrics.http_requests_total}

# HELP http_request_duration_seconds HTTP request latency
# TYPE http_request_duration_seconds histogram
http_request_duration_seconds_bucket{le="0.01"} 10
http_request_duration_seconds_bucket{le="0.05"} 20
http_request_duration_seconds_bucket{le="0.1"} 25
http_request_duration_seconds_bucket{le="+Inf"} ${metrics.http_requests_total}
http_request_duration_seconds_sum 1.5
http_request_duration_seconds_count ${metrics.http_requests_total}

# HELP agents_messages_processed Number of messages processed by agents
# TYPE agents_messages_processed counter
agents_messages_processed{agent="orchestrator"} 0
agents_messages_processed{agent="kubernetes"} 0
agents_messages_processed{agent="terraform"} 0
agents_messages_processed{agent="health"} 0

# HELP process_resident_memory_bytes Resident memory in bytes
# TYPE process_resident_memory_bytes gauge
process_resident_memory_bytes ${memUsage.rss}

# HELP process_heap_alloc_bytes Heap allocated in bytes
# TYPE process_heap_alloc_bytes gauge
process_heap_alloc_bytes ${memUsage.heapUsed}

# HELP process_uptime_seconds Process uptime
# TYPE process_uptime_seconds gauge
process_uptime_seconds ${uptime}

# HELP nodejs_version_info Node.js version information
# TYPE nodejs_version_info gauge
nodejs_version_info{version="${process.version}"} 1
`;

    res.set('Content-Type', 'text/plain; charset=utf-8');
    res.send(prometheusMetrics);
  });

  return router;
}

export function incrementMetrics(metric, value = 1) {
  if (metrics[metric] !== undefined) {
    if (typeof metrics[metric] === 'number') {
      metrics[metric] += value;
    }
  }
}

export { metrics };
export default router;
