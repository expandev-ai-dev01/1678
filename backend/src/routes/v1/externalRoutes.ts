import { Router } from 'express';

const router = Router();

/**
 * @summary External routes configuration
 * @description Public API endpoints that do not require authentication
 */

/**
 * @summary Health check for external services
 */
router.get('/health', (req, res) => {
  res.json({
    status: 'healthy',
    timestamp: new Date().toISOString(),
  });
});

export default router;
