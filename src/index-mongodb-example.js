/**
 * MongoDB Integration Example
 * 
 * Shows how to use MongoDB in your application
 * with the Express.js framework
 */

import express from 'express';
import dotenv from 'dotenv';
import { connectDatabase, closeDatabase, getCollection, getHealthStatus } from './mongodb-client.js';

dotenv.config();

const app = express();
const PORT = process.env.PORT || 3000;

app.use(express.json());

// Middleware: Connect to database on startup
let dbConnected = false;

app.use(async (req, res, next) => {
  if (!dbConnected) {
    try {
      await connectDatabase();
      dbConnected = true;
    } catch (error) {
      console.error('Database connection failed:', error.message);
      return res.status(503).json({
        error: 'Service Unavailable',
        message: 'Database connection failed',
      });
    }
  }
  next();
});

// Health check endpoint
app.get('/health', async (req, res) => {
  const health = await getHealthStatus();
  const statusCode = health.status === 'healthy' ? 200 : 503;
  res.status(statusCode).json({
    status: health.status,
    database: health,
    timestamp: new Date().toISOString(),
  });
});

// Example: Get all users
app.get('/api/users', async (req, res) => {
  try {
    const usersCollection = getCollection('users');
    const users = await usersCollection.find({}).toArray();
    
    res.status(200).json({
      success: true,
      count: users.length,
      users,
    });
  } catch (error) {
    console.error('Error fetching users:', error.message);
    res.status(500).json({
      error: 'Failed to fetch users',
      message: process.env.NODE_ENV === 'development' ? error.message : undefined,
    });
  }
});

// Example: Get user by ID
app.get('/api/users/:id', async (req, res) => {
  try {
    const { id } = req.params;
    const usersCollection = getCollection('users');
    
    // Validate MongoDB ObjectId
    if (!id.match(/^[0-9a-fA-F]{24}$/)) {
      return res.status(400).json({
        error: 'Invalid user ID format',
      });
    }

    const { ObjectId } = await import('mongodb');
    const user = await usersCollection.findOne({ _id: new ObjectId(id) });

    if (!user) {
      return res.status(404).json({
        error: 'User not found',
      });
    }

    res.status(200).json({
      success: true,
      user,
    });
  } catch (error) {
    console.error('Error fetching user:', error.message);
    res.status(500).json({
      error: 'Failed to fetch user',
      message: process.env.NODE_ENV === 'development' ? error.message : undefined,
    });
  }
});

// Example: Create new user
app.post('/api/users', async (req, res) => {
  try {
    const { name, email } = req.body;

    // Validate input
    if (!name || !email) {
      return res.status(400).json({
        error: 'Missing required fields: name, email',
      });
    }

    const usersCollection = getCollection('users');
    const result = await usersCollection.insertOne({
      name,
      email,
      createdAt: new Date(),
    });

    res.status(201).json({
      success: true,
      id: result.insertedId,
      message: 'User created successfully',
    });
  } catch (error) {
    console.error('Error creating user:', error.message);
    res.status(500).json({
      error: 'Failed to create user',
      message: process.env.NODE_ENV === 'development' ? error.message : undefined,
    });
  }
});

// Example: Update user
app.put('/api/users/:id', async (req, res) => {
  try {
    const { id } = req.params;
    const { name, email } = req.body;

    // Validate MongoDB ObjectId
    if (!id.match(/^[0-9a-fA-F]{24}$/)) {
      return res.status(400).json({
        error: 'Invalid user ID format',
      });
    }

    const usersCollection = getCollection('users');
    const { ObjectId } = await import('mongodb');
    
    const result = await usersCollection.updateOne(
      { _id: new ObjectId(id) },
      {
        $set: {
          ...(name && { name }),
          ...(email && { email }),
          updatedAt: new Date(),
        },
      }
    );

    if (result.matchedCount === 0) {
      return res.status(404).json({
        error: 'User not found',
      });
    }

    res.status(200).json({
      success: true,
      message: 'User updated successfully',
    });
  } catch (error) {
    console.error('Error updating user:', error.message);
    res.status(500).json({
      error: 'Failed to update user',
      message: process.env.NODE_ENV === 'development' ? error.message : undefined,
    });
  }
});

// Example: Delete user
app.delete('/api/users/:id', async (req, res) => {
  try {
    const { id } = req.params;

    // Validate MongoDB ObjectId
    if (!id.match(/^[0-9a-fA-F]{24}$/)) {
      return res.status(400).json({
        error: 'Invalid user ID format',
      });
    }

    const usersCollection = getCollection('users');
    const { ObjectId } = await import('mongodb');
    
    const result = await usersCollection.deleteOne({ _id: new ObjectId(id) });

    if (result.deletedCount === 0) {
      return res.status(404).json({
        error: 'User not found',
      });
    }

    res.status(200).json({
      success: true,
      message: 'User deleted successfully',
    });
  } catch (error) {
    console.error('Error deleting user:', error.message);
    res.status(500).json({
      error: 'Failed to delete user',
      message: process.env.NODE_ENV === 'development' ? error.message : undefined,
    });
  }
});

// Error handling middleware
app.use((err, req, res, _next) => {
  console.error('Error:', err);
  res.status(500).json({
    error: 'Internal server error',
    message: process.env.NODE_ENV === 'development' ? err.message : undefined,
  });
});

// 404 handler
app.use((req, res) => {
  res.status(404).json({ error: 'Not found' });
});

// Graceful shutdown
process.on('SIGINT', async () => {
  console.log('\nShutting down gracefully...');
  await closeDatabase();
  process.exit(0);
});

process.on('SIGTERM', async () => {
  console.log('SIGTERM received, shutting down...');
  await closeDatabase();
  process.exit(0);
});

// Start server
const server = app.listen(PORT, () => {
  console.log(`Server running on http://localhost:${PORT}`);
  console.log('📚 API Endpoints:');
  console.log(`  GET    /health                 - Health check`);
  console.log(`  GET    /api/users               - Get all users`);
  console.log(`  GET    /api/users/:id           - Get user by ID`);
  console.log(`  POST   /api/users               - Create new user`);
  console.log(`  PUT    /api/users/:id           - Update user`);
  console.log(`  DELETE /api/users/:id           - Delete user`);
});

export default server;
