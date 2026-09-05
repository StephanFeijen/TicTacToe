// This table stores custom configuration properties for your agent.
// The User Security ID links to the agent user created by the platform.
// TODO: Add your own fields to store agent-specific settings.
// ------------------------------------------------------------------------------------------------

namespace DefaultPublisher;

table 70100 "My Agent Setup"
{
    Access = Internal;
    Caption = 'My Agent Setup';
    DataClassification = CustomerContent;
    InherentEntitlements = RIMDX;
    InherentPermissions = RIMDX;
    ReplicateData = false;
    DataPerCompany = false;

    fields
    {
        // Primary key - links to the agent user created by the platform.
        // Do not modify this field.
        field(1; "User Security ID"; Guid)
        {
            Caption = 'User Security ID';
            ToolTip = 'Specifies the unique identifier for the user.';
            DataClassification = SystemMetadata;
            Editable = false;
        }

        // TODO: Replace or extend with your own fields.
        // Example custom property - modify or remove as needed.
        field(10; "Custom Property"; Text[100])
        {
            Caption = 'Custom Property';
            ToolTip = 'Specifies a custom property for agent-specific configuration.';
            DataClassification = SystemMetadata;
        }

        // TODO: Add additional fields here.
        // Examples:
        // field(11; "Max Retries"; Integer) { Caption = 'Max Retries'; }
        // field(12; "Enable Logging"; Boolean) { Caption = 'Enable Logging'; }
        // field(13; "API Endpoint"; Text[250]) { Caption = 'API Endpoint'; }
    }
    keys
    {
        key(Key1; "User Security ID")
        {
            Clustered = true;
        }
    }
}