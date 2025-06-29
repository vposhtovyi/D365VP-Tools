namespace System.Test.Tooling;

using Microsoft.Finance.GeneralLedger.Account;

codeunit 99919 "BCPT Open Chart of Accounts"
{
    // Test codeunits can only run in foreground (UI)
    Subtype = Test;

    trigger OnRun();
    begin
    end;

    [Test]
    procedure OpenChartAccount()
    var
        ChartAccount: testpage "Chart of Accounts";
    begin
        ChartAccount.OpenView();
        ChartAccount.Close();
    end;
}
