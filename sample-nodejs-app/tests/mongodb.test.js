/**
 * MongoDB Integration Tests
 *
 * Unit tests for MongoDB operations using MongoDB Memory Server
 */

import { MongoMemoryServer } from 'mongodb-memory-server';
import { MongoClient } from 'mongodb';

describe('MongoDB Integration Tests', () => {
  let mongoServer;
  let client;
  let db;

  // Setup: Start in-memory MongoDB
  beforeAll(async () => {
    mongoServer = await MongoMemoryServer.create();
    const mongoUri = mongoServer.getUri();
    client = new MongoClient(mongoUri);
    await client.connect();
    db = client.db('test_db');
  });

  // Teardown: Stop in-memory MongoDB
  afterAll(async () => {
    if (client) {
      await client.close();
    }
    if (mongoServer) {
      await mongoServer.stop();
    }
  });

  describe('Users Collection', () => {
    let usersCollection;

    beforeEach(async () => {
      usersCollection = db.collection('users');
      await usersCollection.deleteMany({});
    });

    test('should insert a user', async () => {
      const user = {
        name: 'John Doe',
        email: 'john@example.com',
        createdAt: new Date(),
      };

      const result = await usersCollection.insertOne(user);

      expect(result.insertedId).toBeDefined();
      expect(result.acknowledged).toBe(true);
    });

    test('should find a user by email', async () => {
      const user = {
        name: 'Jane Doe',
        email: 'jane@example.com',
        createdAt: new Date(),
      };

      await usersCollection.insertOne(user);
      const found = await usersCollection.findOne({ email: 'jane@example.com' });

      expect(found).toBeDefined();
      expect(found.name).toBe('Jane Doe');
      expect(found.email).toBe('jane@example.com');
    });

    test('should find all users', async () => {
      const users = [
        { name: 'User 1', email: 'user1@example.com' },
        { name: 'User 2', email: 'user2@example.com' },
        { name: 'User 3', email: 'user3@example.com' },
      ];

      await usersCollection.insertMany(users);
      const allUsers = await usersCollection.find({}).toArray();

      expect(allUsers.length).toBe(3);
    });

    test('should update a user', async () => {
      const user = {
        name: 'Old Name',
        email: 'update@example.com',
      };

      const insertResult = await usersCollection.insertOne(user);
      const updateResult = await usersCollection.updateOne(
        { _id: insertResult.insertedId },
        { $set: { name: 'New Name' } }
      );

      expect(updateResult.modifiedCount).toBe(1);

      const updated = await usersCollection.findOne({ _id: insertResult.insertedId });
      expect(updated.name).toBe('New Name');
    });

    test('should delete a user', async () => {
      const user = {
        name: 'Delete Me',
        email: 'delete@example.com',
      };

      const insertResult = await usersCollection.insertOne(user);
      const deleteResult = await usersCollection.deleteOne({
        _id: insertResult.insertedId,
      });

      expect(deleteResult.deletedCount).toBe(1);

      const notFound = await usersCollection.findOne({ _id: insertResult.insertedId });
      expect(notFound).toBeNull();
    });

    test('should count users', async () => {
      await usersCollection.insertMany([{ name: 'User 1' }, { name: 'User 2' }]);

      const count = await usersCollection.countDocuments();
      expect(count).toBe(2);
    });
  });

  describe('Database Operations', () => {
    test('should ping database', async () => {
      const result = await db.admin().command({ ping: 1 });
      expect(result.ok).toBe(1);
    });

    test('should list collections', async () => {
      await db.createCollection('test_collection');
      const collections = await db.listCollections().toArray();
      expect(collections.length).toBeGreaterThan(0);
    });
  });
});
