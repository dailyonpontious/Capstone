import { DynamoDBClient, GetItemCommand } from "@aws-sdk/client-dynamodb";
import bcrypt from "bcryptjs";
import jwt from "jsonwebtoken";


const dbClient = new DynamoDBClient({ region: "us-east-1" });
const JWT_SECRET = process.env.JWT_SECRET;
const headers = {
    "Access-Control-Allow-Origin": "*",
    "Access-Control-Allow-Headers": "Content-Type, Authorization",
    "Access-Control-Allow-Methods": "OPTIONS,POST,GET",
  };

export const handler = async (event) => {
    const body = JSON.parse(event.body);
    const { email, password, name } = body;
    try{
        if (!email || !password) {
            return { 
                statusCode: 400, 
                headers: headers,
                body: JSON.stringify({ error: "Missing fields" }) 
            };
        }

        const params = {
            TableName: "Users",
            Key: {
                email: { S: email },
            }
        }
        console.log("Params key", params.Key)

        const result = await dbClient.send(new GetItemCommand(params));
        let user = ""
        if(!result.Item){
            return { 
                statusCode: 404,
                headers: headers,
                body: JSON.stringify({ error: "User not found" }) 
            };
        }else {
            user = result.Item
        }

        const passwordMatch = await bcrypt.compare(password, user.password.S);
        if(!passwordMatch){
            return { 
                statusCode: 401,
                headers: headers, 
                body: JSON.stringify({ error: "Invalid credentials" }) 
            };
        }

        const token = jwt.sign({ 
            userId: user.UserId.S, 
            email: user.email.S }, 
            JWT_SECRET, 
            { expiresIn: '1h' }
        );

        return {
            statusCode: 200,
            headers: headers,
            body: JSON.stringify({ message: "Login successful", token }),
        };

    }catch(err){
        console.error("Login error:", err);
        console.log("Body", body)
        return { 
            statusCode: 500, 
            headers: headers,
            body: JSON.stringify({ error: "Internal server error" }) 
        };
    }
};