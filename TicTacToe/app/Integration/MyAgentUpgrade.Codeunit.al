namespace DefaultPublisher;

// using System.Agents;
// using System.Security.AccessControl;
// using System.Upgrade;

codeunit 70105 "My Agent Upgrade"
{
    Subtype = Upgrade;
    Access = Internal;
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnUpgradePerDatabase()
    begin
        // TODO: Add upgrade logic to update agent instances with the latest instructions/configuration
        // when they need to be changed.
        // UpgradeAgent();
    end;

    // local procedure UpgradeAgent()
    // var
    //     MyAgentSetup: Record "My Agent Setup";
    //     UpgradeTag: Codeunit "Upgrade Tag";
    // begin
    //     if UpgradeTag.HasUpgradeTag(GetUpgradeTag()) then
    //         exit;

    //     if not MyAgentSetup.FindSet() then
    //         exit;

    //     repeat
    //         UpgradeAgentInstructions(MyAgentSetup);
    //     until MyAgentSetup.Next() = 0;

    //     UpgradeTag.SetUpgradeTag(GetUpgradeTag());
    // end;

    // local procedure UpgradeAgentInstructions(var MyAgentSetup: Record "My Agent Setup")
    // var
    //     Agent: Codeunit Agent;
    //     MyAgentSetupCU: Codeunit "My Agent Setup";
    // begin
    //     Agent.SetInstructions(MyAgentSetup."User Security ID", MyAgentSetupCU.GetInstructions());
    // end;

    // [EventSubscriber(ObjectType::Codeunit, Codeunit::"Upgrade Tag", OnGetPerDatabaseUpgradeTags, '', false, false)]
    // local procedure RegisterPerDatabaseTags(var PerDatabaseUpgradeTags: List of [Code[250]])
    // begin
    //     PerDatabaseUpgradeTags.Add(GetUpgradeTag());
    // end;

    // local procedure GetUpgradeTag() : Code[250]
    // begin
    //     exit('MyAgentInstructionUpgradeV2');
    // end;
}
