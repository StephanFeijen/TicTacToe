namespace DefaultPublisher;

table 70101 "My Agent KPI"
{
    Access = Internal;
    Caption = 'My Agent KPI';
    DataClassification = CustomerContent;
    InherentEntitlements = RIMDX;
    InherentPermissions = RIMDX;
    ReplicateData = false;
    DataPerCompany = false;

    fields
    {
        // Primary key - links to the agent user created by the platform.
        field(1; "User Security ID"; Guid)
        {
            Caption = 'User Security ID';
            ToolTip = 'Specifies the unique identifier for the agent user.';
            DataClassification = EndUserPseudonymousIdentifiers;
            Editable = false;
        }

        // TODO: Add your own KPI fields to track agent-specific metrics.
        field(10; "Custom KPI"; Integer)
        {
            Caption = 'Custom KPI';
            ToolTip = 'Specifies a custom KPI for the agent.';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "User Security ID")
        {
            Clustered = true;
        }
    }
}
