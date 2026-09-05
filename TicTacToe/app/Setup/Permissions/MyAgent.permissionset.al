namespace DefaultPublisher;

using System.Security.AccessControl;

permissionset 70100 "My Agent"
{
    Caption = 'My Agent';
    Assignable = true;
    // TODO: Adjust permissions as needed for your agent
    // Tasks will be executed with intersection of user permissions and agent permissions
    IncludedPermissionSets = "D365 BASIC";
}