using OpenAI.Managers;
using OpenAI;

namespace Ors.Innovation.EnhancedAI
{
    using OpenAI.Interfaces;
    using OpenAI.ObjectModels;
    using OpenAI.ObjectModels.RequestModels;
    using System.Text.Json;

    public class Program
    {
        public static async Task Main(string[] args)
        {
            var openAiService = new OpenAIService(
                new OpenAiOptions()
                {
                    ApiKey = "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"
                }
            );

            var trainingDataList = await GetTrainingData();

            if (trainingDataList == null)
            {
                return;
            }

            foreach (var trainingData in trainingDataList)
            {
                var result = await GetEnhancedParameterDescription(
                    openAiService,
                    trainingData.ParameterName,
                    trainingData.FunctionBlock,
                    trainingData.FunctionName
                );

                Console.WriteLine(result);
            }
        }
        private static async Task<List<ParameterDescription>?> GetTrainingData()
        {
            // Specify the path to the JSON file
            string currentDirectory = Directory.GetCurrentDirectory();
            string jsonFilePath = Path.Combine(currentDirectory, "TrainingStructure.json");

            // Check if the JSON file exists
            if (!File.Exists(jsonFilePath))
            {
                return new List<ParameterDescription>();
            }

            var json = await File.ReadAllTextAsync(jsonFilePath);

            return JsonSerializer.Deserialize<List<ParameterDescription>>(json);
        }

        public static async Task<string?> GetEnhancedParameterDescription(OpenAIService openAiService, string parameter, string functionBlock, string functionName)
        {
            var completionResult = await openAiService.ChatCompletion.CreateCompletion(new ChatCompletionCreateRequest
            {
                Messages = new List<ChatMessage>
                {
                    ChatMessage.FromSystem("You are an retail trained ai that is used by consultants to get business knowledge related to what functionalities we have in our application and what parameters are required to activate them"),
                    ChatMessage.FromUser(functionBlock),
                    ChatMessage.FromSystem($"The javascript function name is {functionName}. Use it to gain extra business context regarding what the parameter does."),
                    ChatMessage.FromSystem($"Respond with a medium business summary on what functionality the parameter {parameter} is used for.")
                },
                Model = Models.Gpt_3_5_Turbo_16k
            });

            if (completionResult.Successful)
            {
                return completionResult.Choices.First().Message.Content;
            }

            return null;
        }
    }
}