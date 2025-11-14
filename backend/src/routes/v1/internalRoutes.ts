import { Router } from 'express';

const router = Router();

/**
 * @summary Internal routes configuration
 * @description Authenticated API endpoints for internal application use
 */

/**
 * @summary Health check for internal services
 */
router.get('/health', (req, res) => {
  res.json({
    status: 'healthy',
    timestamp: new Date().toISOString(),
  });
});

export default router;
