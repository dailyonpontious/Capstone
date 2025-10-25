import { DynamoDBClient, PutItemCommand, GetItemCommand} from "@aws-sdk/client-dynamodb";
import bcrypt from "bcryptjs";
import { v4 as uuidv4 } from "uuid";

const dbClient = new DynamoDBClient({ region: "us-east-1" });
const headers = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "Content-Type, Authorization",
  "Access-Control-Allow-Methods": "OPTIONS,POST,GET",
};

export const handler = async (event) => {

  if (event.httpMethod === "OPTIONS") {
    return {
      statusCode: 200,
      headers: headers,
      body: JSON.stringify({}),
    };
  }

  try {
    const body = JSON.parse(event.body);
    const { email, password, name } = body;
    const userId = uuidv4()

    if (!email || !password) {
      return { 
        statusCode: 400, 
        headers: headers,
        body: JSON.stringify({ error: "Missing fields" }) 
      };
    }

    const getParams = {
      TableName: "Users",
      Key: {
        email: { S: email },
      }
    }

    const getResult = await dbClient.send(new GetItemCommand(getParams));

    if(getResult.Item){
      return { 
        statusCode: 409, 
        headers: headers,
        body: JSON.stringify({ error: "User already exsists, try a different one" }) 
      };
    }
    
    const hashed = await bcrypt.hash(password, 10);

    const params = {
      TableName: "Users",
      Item: {
        email: { S: email },
        UserId: { S: userId },
        name: { S: name || "" },
        password: { S: hashed },
      },
      ConditionExpression: "attribute_not_exists(email)", // prevent overwrite
    };

    await dbClient.send(new PutItemCommand(params));

    return {
      statusCode: 201,
      headers: headers,
      body: JSON.stringify({ 
        message: "User created successfully"
      }),
    };

  } catch (err) {
    if (err.name === "ConditionalCheckFailedException") {
      return { 
        statusCode: 409, 
        headers: headers,
        body: JSON.stringify({ error: "User already exists" }) 
      };
    }
    console.error("Signup error:", err);
    return { 
      statusCode: 500, 
      headers: headers,
      body: JSON.stringify({ error: "Internal server error" }) 
    };
  }
};