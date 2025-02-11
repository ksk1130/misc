import boto3
import os
import traceback
from botocore.config import Config

config = Config(
    retries={
        'max_attempts': 10,
        'mode': 'standard'
    }
)

REGION = 'ap-northeast-1'

NUMBER_OF_RESULTS = 5
MODELS = {"claude": "anthropic.claude-3-5-sonnet-20240620-v1:0",
          "RAG_claude": "anthropic.claude-3-5-sonnet-20240620-v1:0",
          "RAG_cohere": "cohere.rerank-v3-5:0"}
KBID = os.getenv('KB_ID')

if KBID is None:
    raise ValueError("KB_ID is not set")


def search(modelName, query):
    modelId = MODELS[modelName]
    print(modelId)

    if modelName.startswith('claude'):
        CLIENT = boto3.client('bedrock-runtime', region_name=REGION, config=config)
    else:
        CLIENT = boto3.client('bedrock-agent-runtime', region_name=REGION, config=config)

    model_package_arn = f"arn:aws:bedrock:{REGION}::foundation-model/{modelId}"

    results = []
    try:
        if modelName.startswith('claude'):
            print('claude')
            CLIENT = boto3.client('bedrock-runtime',
                                  region_name=REGION, config=config)
            messages = [
                {
                    "role": "user",
                    "content": [{"text": query}],
                }
            ]

            inferenceConfig = {
                "temperature": 0.1,
                "topP": 0.9,
                "maxTokens": 500,
                "stopSequences": []
            }

            response = CLIENT.converse(
                modelId=modelId,
                messages=messages,
                inferenceConfig=inferenceConfig
            )

            return response["output"]["message"]["content"][0]["text"]

        elif modelName.startswith('RAG_claude'):
            response = CLIENT.retrieve_and_generate(
                input={"text": query},
                retrieveAndGenerateConfiguration={
                    "type": "KNOWLEDGE_BASE",
                    "knowledgeBaseConfiguration": {
                        "knowledgeBaseId": KBID,
                        "modelArn": model_package_arn,
                        'retrievalConfiguration': {
                            'vectorSearchConfiguration': {
                                'numberOfResults': NUMBER_OF_RESULTS
                            }
                        }
                    },
                },
            )

            for r in response['citations']:
                results.append(r['generatedResponsePart']
                               ['textResponsePart']['text'])

            return "\n".join(results)

        elif modelName.startswith('RAG_cohere'):
            response = CLIENT.retrieve(
                knowledgeBaseId=KBID,
                retrievalConfiguration={
                    'vectorSearchConfiguration': {
                        'numberOfResults': NUMBER_OF_RESULTS,
                        'overrideSearchType': 'SEMANTIC',
                        'rerankingConfiguration': {
                            'bedrockRerankingConfiguration': {
                                "modelConfiguration": {
                                    "modelArn": model_package_arn
                                },
                            },
                            'type': 'BEDROCK_RERANKING_MODEL',
                        },
                    }
                },
                retrievalQuery={
                    'text': query
                },
            )

            for r in response['retrievalResults']:
                results.append(r['content']['text'].replace('     ', ''))

            return "\n".join(results)
        else:
            print(modelId)
            return "Model not found"

    except Exception as e:
        # スタックトレースを表示
        print(traceback.format_exc())

if __name__ == "__main__":
    print(search("claude", "Symfowareについて教えて"))
