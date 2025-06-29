namespace System.Test.Tooling;

using Microsoft.Finance.GeneralLedger.Reports;
using System.Utilities;

codeunit 99917 "BCPT Detail Trial Bal. Report"
{
    trigger OnRun();
    var
        DetailTrialBal: Report "Detail Trial Balance";
        TempBlob: Codeunit "Temp Blob";
        OutStr: OutStream;
    begin
        TempBlob.CreateOutstream(OutStr);
        DetailTrialBal.SaveAs('', ReportFormat::Pdf, OutStr);
    end;
}
