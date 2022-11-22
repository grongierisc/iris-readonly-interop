/// ReadOnly Setup Utility
Class ReadOnly.Setup Extends %Projection.AbstractProjection
{

/// Projection to make install on compile
Projection Reference As Setup;

/// Call of the projection
ClassMethod CreateProjection(cls As %String, ByRef params) As %Status
{
    set tSC = $$$OK
    set tCurrentNamespace = $Namespace

    write !, "Create a tmp file with XData content in it..."
    set tFileName=##class(%File).TempFilename("xml")
    set tFile = ##class(%Stream.FileBinary).%New()
    set tFile.Filename = tFileName 
    write !, "Read the xdata..."
    Set xdataID="ReadOnly.Setup||ReadOnlyInterop"
    Set compiledXdata=##class(%Dictionary.CompiledXData).%OpenId(xdataID)
    Set tStream=compiledXdata.Data
    write !, "Copy Xdata to file..."
    do tFile.CopyFromAndSave(tStream)

    set tObj = ##class(ReadOnly.Setup).%New()
    write !, "Changing namespace to %SYS..."
    znspace "%SYS" // we need to change the namespace to %SYS, as Security.Roles class exists only there
    Try {
      $$$ThrowOnError(tObj.Install(tFileName))
    }
    Catch ex {
      Set tSC=ex.AsStatus()
    } 
    write !, "Changing namespace back to "_tCurrentNamespace_"..."
    znspace tCurrentNamespace
    Return tSC
}

ClassMethod RemoveProjection(cls As %String, ByRef params, recompile As %Boolean) As %Status
{
    Quit $$$OK
}

/// Installer
Method Install(pFileName) As %Status
{
    write !, "Install role #Ready_Only_Interop..."
    $$$ThrowOnError(##class(Security.Roles).Import(pFileName))

    write !, "Create SQL privileges for #Ready_Only_Interop..."
    $$$ThrowOnError(..MakeSearchSQLPrivileges("#Ready_Only_Interop"))

    Return sc
}

Method MakeSearchSQLPrivileges(pRole) As %Status
{
    Set tSC = $$$OK

		// SELECT privileges are assigned to roles which may view message content.
		Set tExtendedSearches = $lb("EnsLib_HL7.Message", "EnsLib_HL7.SearchTable", "EnsLib_EDI_ASTM.Document") _
										$lb("EnsLib_EDI_ASTM.SearchTable", "EnsLib_EDI_EDIFACT.Document", "EnsLib_EDI_EDIFACT.SearchTable") _
										$lb("EnsLib_EDI_X12.Document", "EnsLib_EDI_X12.SearchTable","EnsLib_EDI_XML.Document") _
										$lb("EnsLib_XML.SearchTable", "EnsLib_EDI_XML.SearchTable", "Ens.MessageBody", "EnsLib_RecordMap.Batch") _
										$lb("EnsLib_DICOM.Document", "EnsLib_ebXML.Message", "EnsLib_ebXML.MessageWithPayload") _
										$lb("EnsLib_ebXML.MessageTracking", "EnsLib_Printing.PrintJob", "EnsLib_Printing.PrintRequest") _
										$lb("EnsLib_SQL.Snapshot", "Ens.StreamContainer", "Ens.StringContainer") _
										$lb("Ens_Util.IOLog", $lb("EnsLib_Agent.Interface",0,"u"))

    Set tSearches = $lb("Ens_Util.Log", "Ens.MessageHeader", "Ens.SuperSessionIndex", "Ens_Config.Credentials", "Ens_Rule.RuleLog", "Ens_Rule.Log", "Ens_Rule.DebugLog") _ 
												$lb("Ens_Util.Calendar", "Ens.BusinessProcess", "Ens.BusinessProcessBPL", "Ens_Enterprise_MsgBank.MessageHeader") _
												$lb("Ens_Enterprise_MsgBank.Log", "Ens_Enterprise_MsgBank.Node", "Ens_Util.Schedule", "Ens_Enterprise.MonitorClient") _
												$lb("EnsLib_ITK_DTS_Framework.TransferLog", "EnsLib_ITK_Framework.FaultCode", "EnsLib_ITK_Framework.FaultVocabulary") _
												$lb("EnsLib_ITK_Framework.FaultVocabularyMap", "EnsLib_ITK_Setup.ConsumerServiceRegistry", "EnsLib_ITK_Setup.DistributionRules") _
												$lb("EnsLib_ITK_Setup.SenderRegistry", "EnsLib_ITK_Setup.ServiceDefinition", "EnsLib_ITK_Setup.SubscriptionRules") _
												$lb("EnsLib_ITK_Setup.SystemDefinition", "Ens_Alerting.ManagedAlert","EnsLib_Agent.Interface") _
												$lb("Ens_ServiceRegistry_External.Service","Ens_ServiceRegistry_External.Attribute") _
												$lb("ISC_DM.IRISInteroperabilityPorts")

    Set tProductionSearche = $lb("Ens_Config.Production_Extent")

    Set tRoles(pRole) = tExtendedSearches_tSearches_tProductionSearche

    set tNamespace = ""
    While $order(^%SYS("Ensemble","InstalledNamespace",tNamespace))'="" {
      set tNamespace = $order(^%SYS("Ensemble","InstalledNamespace",tNamespace))  
      For i=1:1:$ll(tRoles(pRole)) {
        Set tTable = $lg(tRoles(pRole), i)
        If $ListValid(tTable) {
          Set tGrantable = +$lg(tTable, 2)
          Set tPriv = $lg(tTable, 3, "s")
          Set tTable = $lg(tTable, 1)
        }
        Else {
          Set tGrantable = 0
          Set tPriv = "s"
        }
        Set tSQLObject = "1,"_tTable
        Set tStatus = ..addSQLPrivilege(tNamespace, tSQLObject, tPriv, pRole, tGrantable)
        If $$$ISERR(tStatus) Quit
      }
      
    }

    Return tSC
}

Method addSQLPrivilege(pNamespace As %String, pSQLObject As %String, pPrivilege As %String, pGrantee As %String, pGrantable As %Boolean = 0, pGrantor As %String = "_Ensemble") As %Status
{
	Set tStatus = $$$OK
	For i=1:1:$l(pPrivilege) {
		Set tPrivilege = $e(pPrivilege,i)
		If '##class(Security.SQLPrivileges).IDKeyExists(pNamespace, pSQLObject, tPrivilege, pGrantee, pGrantor) {
			Set tSQLPriv = ##class(Security.SQLPrivileges).%New()
			Set tSQLPriv.Namespace = pNamespace
			Set tSQLPriv.SQLObject = pSQLObject
			Set tSQLPriv.Grantable = pGrantable
			Set tSQLPriv.Grantee = pGrantee
			Set tSQLPriv.Privilege = tPrivilege
			Set tSQLPriv.Grantor = pGrantor
			Set tStatus = tSQLPriv.%Save()
			If $$$ISERR(tStatus) Quit
		}
	}
	Quit tStatus
}

/// Description
XData ReadOnlyInterop
{
<?xml version="1.0" encoding="UTF-8"?>
<RolesExport>
  <Roles>
    <Description>Interoperability Operator</Description>
    <Name>#Ready_Only_Interop</Name>
    <Resources>
      <Resource>
        <Name>%Ens_Agents</Name>
        <Permission>1</Permission>
      </Resource>
      <Resource>
        <Name>%Ens_AlertAdministration</Name>
        <Permission>1</Permission>
      </Resource>
      <Resource>
        <Name>%Ens_Alerts</Name>
        <Permission>3</Permission>
      </Resource>
      <Resource>
        <Name>%Ens_ArchiveManager</Name>
        <Permission>1</Permission>
      </Resource>
      <Resource>
        <Name>%Ens_BPL</Name>
        <Permission>1</Permission>
      </Resource>
      <Resource>
        <Name>%Ens_BusinessRules</Name>
        <Permission>1</Permission>
      </Resource>
      <Resource>
        <Name>%Ens_Code</Name>
        <Permission>1</Permission>
      </Resource>
      <Resource>
        <Name>%Ens_ConfigItemRun</Name>
        <Permission>1</Permission>
      </Resource>
      <Resource>
        <Name>%Ens_Credentials</Name>
        <Permission>5</Permission>
      </Resource>
      <Resource>
        <Name>%Ens_DTL</Name>
        <Permission>5</Permission>
      </Resource>
      <Resource>
        <Name>%Ens_DTLTest</Name>
        <Permission>1</Permission>
      </Resource>
      <Resource>
        <Name>%Ens_Dashboard</Name>
        <Permission>4</Permission>
      </Resource>
      <Resource>
        <Name>%Ens_Deploy</Name>
        <Permission>1</Permission>
      </Resource>
      <Resource>
        <Name>%Ens_DeploymentPkg</Name>
        <Permission>1</Permission>
      </Resource>
      <Resource>
        <Name>%Ens_DeploymentPkgClient</Name>
        <Permission>1</Permission>
      </Resource>
      <Resource>
        <Name>%Ens_EDISchema</Name>
        <Permission>1</Permission>
      </Resource>
      <Resource>
        <Name>%Ens_EDISchemaAnnotations</Name>
        <Permission>1</Permission>
      </Resource>
      <Resource>
        <Name>%Ens_EventLog</Name>
        <Permission>4</Permission>
      </Resource>
      <Resource>
        <Name>%Ens_ITK</Name>
        <Permission>1</Permission>
      </Resource>
      <Resource>
        <Name>%Ens_Jobs</Name>
        <Permission>1</Permission>
      </Resource>
      <Resource>
        <Name>%Ens_LookupTables</Name>
        <Permission>1</Permission>
      </Resource>
      <Resource>
        <Name>%Ens_MessageContent</Name>
        <Permission>4</Permission>
      </Resource>
      <Resource>
        <Name>%Ens_MessageDiscard</Name>
        <Permission>1</Permission>
      </Resource>
      <Resource>
        <Name>%Ens_MessageEditResend</Name>
        <Permission>1</Permission>
      </Resource>
      <Resource>
        <Name>%Ens_MessageExport</Name>
        <Permission>1</Permission>
      </Resource>
      <Resource>
        <Name>%Ens_MessageHeader</Name>
        <Permission>4</Permission>
      </Resource>
      <Resource>
        <Name>%Ens_MessageResend</Name>
        <Permission>1</Permission>
      </Resource>
      <Resource>
        <Name>%Ens_MessageSuspend</Name>
        <Permission>1</Permission>
      </Resource>
      <Resource>
        <Name>%Ens_MessageTrace</Name>
        <Permission>4</Permission>
      </Resource>
      <Resource>
        <Name>%Ens_MsgBank</Name>
        <Permission>1</Permission>
      </Resource>
      <Resource>
        <Name>%Ens_MsgBankConfig</Name>
        <Permission>1</Permission>
      </Resource>
      <Resource>
        <Name>%Ens_MsgBank_Dashboard</Name>
        <Permission>4</Permission>
      </Resource>
      <Resource>
        <Name>%Ens_MsgBank_EventLog</Name>
        <Permission>4</Permission>
      </Resource>
      <Resource>
        <Name>%Ens_MsgBank_MessageContent</Name>
        <Permission>1</Permission>
      </Resource>
      <Resource>
        <Name>%Ens_MsgBank_MessageEditResend</Name>
        <Permission>1</Permission>
      </Resource>
      <Resource>
        <Name>%Ens_MsgBank_MessageHeader</Name>
        <Permission>4</Permission>
      </Resource>
      <Resource>
        <Name>%Ens_MsgBank_MessageResend</Name>
        <Permission>4</Permission>
      </Resource>
      <Resource>
        <Name>%Ens_MsgBank_MessageTrace</Name>
        <Permission>4</Permission>
      </Resource>
      <Resource>
        <Name>%Ens_PortSettingsReport</Name>
        <Permission>1</Permission>
      </Resource>
      <Resource>
        <Name>%Ens_Portal</Name>
        <Permission>4</Permission>
      </Resource>
      <Resource>
        <Name>%Ens_ProductionConfig</Name>
        <Permission>5</Permission>
      </Resource>
      <Resource>
        <Name>%Ens_ProductionDocumentation</Name>
        <Permission>5</Permission>
      </Resource>
      <Resource>
        <Name>%Ens_ProductionRun</Name>
        <Permission>1</Permission>
      </Resource>
      <Resource>
        <Name>%Ens_PubSub</Name>
        <Permission>1</Permission>
      </Resource>
      <Resource>
        <Name>%Ens_Purge</Name>
        <Permission>1</Permission>
      </Resource>
      <Resource>
        <Name>%Ens_PurgeSchedule</Name>
        <Permission>1</Permission>
      </Resource>
      <Resource>
        <Name>%Ens_PurgeSettings</Name>
        <Permission>1</Permission>
      </Resource>
      <Resource>
        <Name>%Ens_Queues</Name>
        <Permission>1</Permission>
      </Resource>
      <Resource>
        <Name>%Ens_RecordMap</Name>
        <Permission>1</Permission>
      </Resource>
      <Resource>
        <Name>%Ens_RestrictedUI_SystemDefaultSettings</Name>
        <Permission>1</Permission>
      </Resource>
      <Resource>
        <Name>%Ens_RoutingRules</Name>
        <Permission>5</Permission>
      </Resource>
      <Resource>
        <Name>%Ens_RuleLog</Name>
        <Permission>4</Permission>
      </Resource>
      <Resource>
        <Name>%Ens_Rules</Name>
        <Permission>5</Permission>
      </Resource>
      <Resource>
        <Name>%Ens_SettingsReportConfig</Name>
        <Permission>1</Permission>
      </Resource>
      <Resource>
        <Name>%Ens_SystemDefaultConfig</Name>
        <Permission>1</Permission>
      </Resource>
      <Resource>
        <Name>%Ens_SystemDefaultSettings_AllowedIPAddresses</Name>
        <Permission>1</Permission>
      </Resource>
      <Resource>
        <Name>%Ens_SystemDefaultSettings_IPAddress</Name>
        <Permission>1</Permission>
      </Resource>
      <Resource>
        <Name>%Ens_SystemDefaultSettings_Port</Name>
        <Permission>1</Permission>
      </Resource>
      <Resource>
        <Name>%Ens_SystemDefaultSettings_Server</Name>
        <Permission>1</Permission>
      </Resource>
      <Resource>
        <Name>%Ens_TestingService</Name>
        <Permission>1</Permission>
      </Resource>
      <Resource>
        <Name>%Ens_ViewFileSystem</Name>
        <Permission>1</Permission>
      </Resource>
      <Resource>
        <Name>%Ens_WorkflowConfig</Name>
        <Permission>1</Permission>
      </Resource>
    </Resources>
  </Roles>
</RolesExport>
}

}
