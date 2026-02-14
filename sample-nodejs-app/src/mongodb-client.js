/**
 * MongoDB Client Module
 *
 * Handles MongoDB connection pooling and database access
 * for the application
 */

import { MongoClient } from 'mongodb';
import dotenv from 'dotenv';

dotenv.config();

// Configuration
const MONGO_URI = process.env.MONGO_URI || 'mongodb://localhost:27017';
const MONGO_DB_NAME = process.env.MONGO_DB_NAME || 'app_db';
const MONGO_MAX_POOL_SIZE = parseInt(process.env.MONGO_MAX_POOL_SIZE || '50', 10);
const MONGO_MIN_POOL_SIZE = parseInt(process.env.MONGO_MIN_POOL_SIZE || '10', 10);

let mongoClient = null;
let db = null;

/**
 * Connect to MongoDB
 * Establishes connection with connection pooling
 */
export async function connectDatabase() {
  if (mongoClient?.topology?.isConnected?.()) {
    console.log('[MongoDB] Already connected to database');
    return mongoClient;
  }

  try {
    console.log('[MongoDB] Connecting to MongoDB...');

    mongoClient = new MongoClient(MONGO_URI, {
      maxPoolSize: MONGO_MAX_POOL_SIZE,
      minPoolSize: MONGO_MIN_POOL_SIZE,
      serverSelectionTimeoutMS: 5000,
      connectTimeoutMS: 10000,
      socketTimeoutMS: 45000,
    });

    await mongoClient.connect();
    db = mongoClient.db(MONGO_DB_NAME);

    // Verify connection
    await db.admin().command({ ping: 1 });
    console.log('[MongoDB] ✅ Connected successfully');
    console.log('[MongoDB] Database:', MONGO_DB_NAME);

    return mongoClient;
  } catch (error) {
    console.error('[MongoDB] ❌ Connection failed:', error.message);
    throw new Error(`MongoDB connection failed: ${error.message}`);
  }
}

/**
 * Close MongoDB connection
 */
export async function closeDatabase() {
  if (mongoClient) {
    try {
      await mongoClient.close();
      console.log('[MongoDB] ✅ Connection closed');
      mongoClient = null;
      db = null;
    } catch (error) {
      console.error('[MongoDB] ❌ Error closing connection:', error.message);
      throw error;
    }
  }
}

/**
 * Get database instance
 * Must call connectDatabase() first
 */
export function getDatabase() {
  if (!db) {
    throw new Error('Database not connected. Call connectDatabase() first.');
  }
  return db;
}

/**
 * Get MongoDB client
 */
export function getClient() {
  if (!mongoClient) {
    throw new Error('Client not connected. Call connectDatabase() first.');
  }
  return mongoClient;
}

/**
 * Check if database is connected
 */
export function isConnected() {
  return mongoClient?.topology?.isConnected?.() ?? false;
}

/**
 * Get connection health status
 */
export async function getHealthStatus() {
  try {
    if (!isConnected()) {
      return {
        status: 'disconnected',
        connected: false,
      };
    }

    const startTime = Date.now();
    const result = await getDatabase().admin().command({ ping: 1 });
    const responseTime = Date.now() - startTime;

    return {
      status: result.ok === 1 ? 'healthy' : 'unhealthy',
      connected: true,
      responseTime,
      timestamp: new Date().toISOString(),
    };
  } catch (error) {
    return {
      status: 'error',
      connected: false,
      error: error.message,
      timestamp: new Date().toISOString(),
    };
  }
}

/**
 * Get collection
 * Convenience method for accessing collections
 */
export function getCollection(collectionName) {
  return getDatabase().collection(collectionName);
}

export default {
  connectDatabase,
  closeDatabase,
  getDatabase,
  getClient,
  isConnected,
  getHealthStatus,
  getCollection,
};
