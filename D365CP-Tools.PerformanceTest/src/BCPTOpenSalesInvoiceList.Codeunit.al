namespace System.Test.Tooling;

using Microsoft.Sales.Document;

codeunit 99924 "BCPT Open Sales Invoice List"
{
    // Test codeunits can only run in foreground (UI)
    Subtype = Test;

    trigger OnRun();
    begin
    end;

    [Test]
    procedure OpenSalesInvoiceList()
    var
        SalesInvoiceList: testpage "Sales Invoice List";
    begin
        SalesInvoiceList.OpenView();
        SalesInvoiceList.Close();
    end;
}
