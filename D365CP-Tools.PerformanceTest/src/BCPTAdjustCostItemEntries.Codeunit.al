namespace System.Test.Tooling;

using Microsoft.Inventory.Costing;

codeunit 99933 "BCPT Adjust Cost Item Entries"
{
    trigger OnRun()
    begin
        AdjusCostItemEntries();
    end;

    local procedure AdjusCostItemEntries()
    var
        AdjustCostItemEntries: Report "Adjust Cost - Item Entries";
    begin
        //Adjust and post to GL
        AdjustCostItemEntries.SetPostToGL(true);
        AdjustCostItemEntries.UseRequestPage(false);
        AdjustCostItemEntries.Run();
    end;
}
