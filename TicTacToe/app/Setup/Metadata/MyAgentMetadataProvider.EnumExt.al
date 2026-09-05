namespace DefaultPublisher;

using System.Agents;

enumextension 70101 "My Agent Metadata Provider" extends "Agent Metadata Provider"
{
    value(70101; "My Agent") // TODO: Rename your agent type, must be unique
    {
        Caption = 'My Agent'; // TODO: Update caption for your agent type
        Implementation = IAgentFactory = MyAgentFactory, IAgentMetadata = MyAgentMetadata, IAgentTaskExecution = MyAgentTaskExecution;
    }
}