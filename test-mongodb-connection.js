/**
 * MongoDB Connection Test Script
 *
 * This script tests the MongoDB connection from your Node.js application
 * and validates that all dependencies are properly configured.
 *
 * Usage: node test-mongodb-connection.js
 */

import { MongoClient } from 'mongodb';
import dotenv from 'dotenv';

// Load environment variables
dotenv.config();

// Configuration
const MONGO_URI = process.env.MONGO_URI || 'mongodb://localhost:27017';
const MONGO_DB_NAME = process.env.MONGO_DB_NAME || 'test_db';

// Color output utilities
const colors = {
  reset: '\x1b[0m',
  bright: '\x1b[1m',
  dim: '\x1b[2m',
  red: '\x1b[31m',
  green: '\x1b[32m',
  yellow: '\x1b[33m',
  blue: '\x1b[36m',
};

function log(message, color = 'reset') {
  console.log(`${colors[color]}${message}${colors.reset}`);
}

function logSuccess(message) {
  log(`✅ ${message}`, 'green');
}

function logError(message) {
  log(`❌ ${message}`, 'red');
}

function logWarning(message) {
  log(`⚠️  ${message}`, 'yellow');
}

function logInfo(message) {
  log(`ℹ️  ${message}`, 'blue');
}

function logHeader(title) {
  log('\n' + '='.repeat(50), 'bright');
  log(title, 'bright');
  log('='.repeat(50) + '\n', 'bright');
}

/**
 * Test MongoDB Connection
 */
async function testConnection() {
  const client = new MongoClient(MONGO_URI, {
    serverSelectionTimeoutMS: 5000,
    connectTimeoutMS: 10000,
  });

  logHeader('MongoDB Connection Test');

  try {
    // Test 1: Connection
    logInfo('Test 1: Connecting to MongoDB...');
    const startTime = Date.now();
    await client.connect();
    const connectionTime = Date.now() - startTime;
    logSuccess(`Connected to MongoDB (${connectionTime}ms)`);

    // Test 2: Ping
    logInfo('Test 2: Sending ping command...');
    const pingResult = await client.db('admin').command({ ping: 1 });
    logSuccess(`Ping response: ${JSON.stringify(pingResult)}`);

    // Test 3: List Databases
    logInfo('Test 3: Listing available databases...');
    const adminDb = client.db('admin');
    const databases = await adminDb.admin().listDatabases();
    logSuccess(`Found ${databases.databases.length} database(s):`);
    databases.databases.forEach((db) => {
      log(`  - ${db.name} (${(db.sizeOnDisk / 1024 / 1024).toFixed(2)} MB)`, 'dim');
    });

    // Test 4: Test Database Operations
    logInfo('Test 4: Testing basic database operations...');
    const testDb = client.db(MONGO_DB_NAME);

    // Create a collection
    const collection = testDb.collection('test_collection');

    // Insert document
    const insertResult = await collection.insertOne({
      test: 'MongoDB Connection Test',
      timestamp: new Date(),
      status: 'success',
    });
    logSuccess(`Document inserted with ID: ${insertResult.insertedId}`);

    // Find document
    const foundDocument = await collection.findOne({ _id: insertResult.insertedId });
    logSuccess(`Document retrieved: ${JSON.stringify(foundDocument)}`);

    // Count documents
    const count = await collection.countDocuments();
    logSuccess(`Collection contains ${count} document(s)`);

    // Delete test document
    const deleteResult = await collection.deleteOne({ _id: insertResult.insertedId });
    logSuccess(`Document deleted (${deleteResult.deletedCount} document(s) removed)`);

    // Test 5: Server Info
    logInfo('Test 5: Retrieving server information...');
    const serverStatus = await client.db('admin').command({ serverStatus: 1 });
    const memoryInfo = {
      uptime: serverStatus.uptime,
      version: serverStatus.version,
      host: serverStatus.host,
    };
    logSuccess(`Server Info: ${JSON.stringify(memoryInfo, null, 2)}`);

    // Test 6: Connection Pool Stats
    logInfo('Test 6: Checking connection pool...');
    const topology = client.topology;
    const poolStats = {
      connected: topology.isConnected(),
      readyState: topology.s?.state,
    };
    logSuccess(`Connection Pool: Connected=${poolStats.connected}`);

    // Summary
    logHeader('✨ All Tests Passed!');
    log('Your MongoDB installation is working correctly.', 'green');
    log('You can now proceed with development.', 'green');
    log('\nConnection Details:', 'bright');
    log(`  URI: ${MONGO_URI.replace(/:[^@]*@/, ':****@')}`, 'dim');
    log(`  Database: ${MONGO_DB_NAME}`, 'dim');
  } catch (error) {
    // Error handling
    logError(`Test failed: ${error.message}`);

    logHeader('❌ Connection Test Failed');

    // Detailed error information
    log('\nError Details:', 'bright');
    log(`  Error Type: ${error.name}`, 'dim');
    log(`  Error Code: ${error.code}`, 'dim');
    log(`  Error Message: ${error.message}`, 'dim');

    // Troubleshooting suggestions
    log('\nTroubleshooting Steps:', 'bright');

    if (error.message.includes('ECONNREFUSED')) {
      logWarning('Connection refused - MongoDB may not be running');
      log('  1. Check if MongoDB service is running:', 'dim');
      log('     Windows: Get-Service mongod', 'dim');
      log('     macOS: brew services list', 'dim');
      log('     Linux: sudo systemctl status mongod', 'dim');
      log('  2. Verify MongoDB is listening on the correct port:', 'dim');
      log('     mongosh mongodb://localhost:27017', 'dim');
    }

    if (error.message.includes('authentication failed')) {
      logWarning('Authentication failed - Check credentials');
      log('  1. Verify MONGO_URI in .env file', 'dim');
      log('  2. Check username and password are correct', 'dim');
      log('  3. Ensure user has access to the database', 'dim');
    }

    if (error.message.includes('Timeout')) {
      logWarning('Connection timeout - Network or server issue');
      log('  1. Check firewall settings (port 27017)', 'dim');
      log('  2. Verify MongoDB is running and responsive', 'dim');
      log('  3. Check network connectivity', 'dim');
    }

    if (error.message.includes('ENOTFOUND')) {
      logWarning('Host not found - Check connection string');
      log('  1. Verify hostname in MONGO_URI', 'dim');
      log('  2. For remote connections, ensure host is accessible', 'dim');
      log('  3. Check DNS resolution', 'dim');
    }

    log('\nFor more help, see MONGODB_SETUP.md - Section 7: Troubleshooting', 'dim');

    process.exit(1);
  } finally {
    // Cleanup
    logInfo('Closing MongoDB connection...');
    await client.close();
    logSuccess('Connection closed');
  }
}

/**
 * Display environment information
 */
function displayEnvironment() {
  logHeader('Environment Information');
  log(`Node.js Version: ${process.version}`, 'dim');
  log(`Platform: ${process.platform}`, 'dim');
  log(`MONGO_URI: ${MONGO_URI.replace(/:[^@]*@/, ':****@')}`, 'dim');
  log(`Database: ${MONGO_DB_NAME}`, 'dim');
  log(`NODE_ENV: ${process.env.NODE_ENV || 'not set'}`, 'dim');
  log('');
}

/**
 * Main execution
 */
async function main() {
  displayEnvironment();

  try {
    await testConnection();
  } catch (error) {
    logError(`Unexpected error: ${error.message}`);
    process.exit(1);
  }
}

// Run tests
main();
