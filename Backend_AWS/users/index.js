import { DynamoDBClient, PutItemCommand } from "@aws-sdk/client-dynamodb";
import bcrypt from "bcryptjs";
import { v4 as uuidv4 } from "uuid";

const dbClient = new DynamoDBClient({ region: "us-east-2" });

export const handler = async (event) => {
  try {
    const body = JSON.parse(event.body);
    const { email, password, name } = body;

    if (!email || !password) {
      return { statusCode: 400, body: JSON.stringify({ error: "Missing fields" }) };
    }

    const hashed = await bcrypt.hash(password, 10);

    const params = {
      TableName: "User",
      Item: {
        UserId: { S: uuidv4() },
        email: { S: email },
        name: { S: name || "" },
        password: { S: hashed },
      },
      ConditionExpression: "attribute_not_exists(email)", // prevent overwrite
    };

    await dbClient.send(new PutItemCommand(params));

    return {
      statusCode: 201,
      body: JSON.stringify({ message: "User created successfully" }),
    };

  } catch (err) {
    if (err.name === "ConditionalCheckFailedException") {
      return { statusCode: 409, body: JSON.stringify({ error: "User already exists" }) };
    }
    console.error("Signup error:", err);
    return { statusCode: 500, body: JSON.stringify({ error: "Internal server error" }) };
  }
};