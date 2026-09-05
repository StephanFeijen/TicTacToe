namespace DefaultPublisher;

using System.Agents;
using System.Reflection;
using System.Security.AccessControl;

codeunit 70103 "My Agent Setup"
{
    Access = Internal;

    procedure GetInitials(): Text[4]
    begin
        exit(AgentInitialsLbl);
    end;

    procedure GetSetupPageId(): Integer
    begin
        exit(Page::"My Agent Setup");
    end;

    procedure GetSummaryPageId(): Integer
    begin
        exit(Page::"My Agent KPI");
    end;

    /// <summary>
    /// Gets the instructions from resources.
    /// </summary>
    /// <returns>The instructions.</returns>
    /// <remarks>The function can return Text if the instructions should be open.</remarks>
    [NonDebuggable]
    procedure GetInstructions(): SecretText
    var
        Instructions: Text;
    begin
        // TODO: Update this code to load instructions from wherever they are stored.
        Instructions := NavApp.GetResourceAsText('Instructions/InstructionsV1.txt');
        exit(Instructions);
    end;

    procedure GetDefaultProfile(var TempAllProfile: Record "All Profile" temporary)
    var
        CurrentModuleInfo: ModuleInfo;
    begin
        NavApp.GetCurrentModuleInfo(CurrentModuleInfo);
        Agent.PopulateDefaultProfile(DefaultProfileTok, CurrentModuleInfo.Id, TempAllProfile);
    end;

    procedure GetDefaultAccessControls(var TempAccessControlBuffer: Record "Access Control Buffer" temporary)
    var
        CurrentModuleInfo: ModuleInfo;
    begin
        NavApp.GetCurrentModuleInfo(CurrentModuleInfo);
        Clear(TempAccessControlBuffer);
        TempAccessControlBuffer."Company Name" := CopyStr(CompanyName(), 1, MaxStrLen(TempAccessControlBuffer."Company Name"));
        TempAccessControlBuffer.Scope := TempAccessControlBuffer.Scope::System;
        TempAccessControlBuffer."App ID" := CurrentModuleInfo.Id;
        TempAccessControlBuffer."Role ID" := DefaultPermissionSetTok;
        TempAccessControlBuffer.Insert();
    end;

    procedure GetAgentMetadataProvider(): Enum "Agent Metadata Provider"
    begin
        exit(Enum::"Agent Metadata Provider"::"My Agent");
    end;

    procedure GetAgentUserName(): Code[50]
    begin
        exit(CopyStr(AgentNameLbl + ' - ' + CompanyName(), 1, 50));
    end;

    procedure GetDefaultDisplayName(): Text[80]
    begin
        exit(DefaultDisplayNameLbl);
    end;

    procedure GetAgentSummary(): Text
    begin
        exit(AgentSummaryLbl);
    end;

    procedure InitializeSetupRecord(var TempMyAgentSetup: Record "My Agent Setup" temporary)
    var
        MyAgentSetupRecord: Record "My Agent Setup";
    begin
        if IsNullGuid(TempMyAgentSetup."User Security ID") then
            TempMyAgentSetup."Custom Property" := DefaultCustomPropertyLbl
        else
            if MyAgentSetupRecord.Get(TempMyAgentSetup."User Security ID") then
                TempMyAgentSetup.TransferFields(MyAgentSetupRecord, false);

        if TempMyAgentSetup.IsEmpty() then
            TempMyAgentSetup.Insert();
    end;

    procedure SaveSetupRecord(var TempMyAgentSetup: Record "My Agent Setup" temporary; var AgentSetupBuffer: Record "Agent Setup Buffer")
    var
        MyAgentSetupRecord: Record "My Agent Setup";
        AgentSetup: Codeunit "Agent Setup";
        IsNewAgent: Boolean;
    begin
        IsNewAgent := IsNullGuid(AgentSetupBuffer."User Security ID");

        if AgentSetup.GetChangesMade(AgentSetupBuffer) then begin
            TempMyAgentSetup."User Security ID" := AgentSetup.SaveChanges(AgentSetupBuffer);

            if IsNewAgent then
                Agent.SetInstructions(TempMyAgentSetup."User Security ID", GetInstructions());
        end;
    end;

    procedure SaveCustomProperties(var TempMyAgentSetup: Record "My Agent Setup" temporary)
    var
        MyAgentSetupRecord: Record "My Agent Setup";
    begin
        // TODO: Save any custom properties defined in the setup record.
        if not MyAgentSetupRecord.Get(TempMyAgentSetup."User Security ID") then begin
            MyAgentSetupRecord.Init();
            MyAgentSetupRecord."User Security ID" := TempMyAgentSetup."User Security ID";
        end;

        MyAgentSetupRecord."Custom Property" := TempMyAgentSetup."Custom Property";

        if not MyAgentSetupRecord.Modify() then
            MyAgentSetupRecord.Insert();
    end;

    var
        Agent: Codeunit Agent;
        // TODO: Adjust default permission set
        DefaultPermissionSetTok: Label 'MY AGENT', Locked = true;
        DefaultProfileTok: Label 'MY AGENT PROFILE', Locked = true;
        AgentInitialsLbl: Label 'GEN', MaxLength = 4;
        AgentNameLbl: Label 'My Agent';
        DefaultDisplayNameLbl: Label 'My Agent';
        AgentSummaryLbl: Label 'The description of what my agent does.';
        DefaultCustomPropertyLbl: Label 'Default Value', Locked = true;
}