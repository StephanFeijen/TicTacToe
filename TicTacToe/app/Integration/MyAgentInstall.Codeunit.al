namespace DefaultPublisher;

using System.Agents;
using System.AI;
using System.Security.AccessControl;

codeunit 70101 "My Agent Install"
{
    Subtype = Install;
    Access = Internal;
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnInstallAppPerDatabase()
    var
        MyAgentSetup: Record "My Agent Setup";
    begin
        RegisterCapability();

        if not MyAgentSetup.FindSet() then
            exit;

        repeat
            InstallAgent(MyAgentSetup);
        until MyAgentSetup.Next() = 0;
    end;

    local procedure InstallAgent(var MyAgentSetup: Record "My Agent Setup")
    begin
        InstallAgentInstructions(MyAgentSetup);
        InstallAccessControl(MyAgentSetup);
        InstallAgentSetup(MyAgentSetup);
    end;

    local procedure InstallAgentInstructions(var MyAgentSetup: Record "My Agent Setup")
    var
        Agent: Codeunit Agent;
        MyAgentSetupCU: Codeunit "My Agent Setup";
    begin
        Agent.SetInstructions(MyAgentSetup."User Security ID", MyAgentSetupCU.GetInstructions());
    end;

    local procedure InstallAccessControl(var MyAgentSetup: Record "My Agent Setup")
    var
        Agent: Codeunit Agent;
        TempAgentAccessControl: Record "Access Control Buffer" temporary;
    begin
        // TODO: Override access control install logic if needed
        // Agent.UpdateAccessControl(MyAgentSetup."User Security ID", TempAgentAccessControl);
    end;

    local procedure InstallAgentSetup(var MyAgentSetup: Record "My Agent Setup")
    begin
        // TODO: Custom install logic for My Agent Setup record if needed
    end;

    local procedure RegisterCapability()
    var
        CopilotCapability: Codeunit "Copilot Capability";
        LearnMoreUrlTxt: Label 'link-to-my-documentation', Locked = true; // TODO: Update with actual documentation URL
    begin
        if CopilotCapability.IsCapabilityRegistered(Enum::"Copilot Capability"::"My Agent Capability") then
            CopilotCapability.UnregisterCapability(Enum::"Copilot Capability"::"My Agent Capability");

        // Register capability
        CopilotCapability.RegisterCapability(
        Enum::"Copilot Capability"::"My Agent Capability",
        Enum::"Copilot Availability"::Preview,
        "Copilot Billing Type"::"Microsoft Billed",
        LearnMoreUrlTxt)
    end;
}