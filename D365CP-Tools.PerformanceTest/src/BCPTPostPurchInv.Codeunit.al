namespace System.Test.Tooling;

using Microsoft.Foundation.NoSeries;
using Microsoft.Inventory.Item;
using Microsoft.Purchases.Document;
using Microsoft.Purchases.Posting;
using Microsoft.Purchases.Setup;
using Microsoft.Purchases.Vendor;
using System.Tooling;

codeunit 99932 "BCPT Post Purch. Inv." implements "BCPT Test Param. Provider"
{
    SingleInstance = true;

    trigger OnRun();
    begin
        if not IsInitialized then begin
            InitTest();
            IsInitialized := true;
        end;

        CreateAndPostPurchaseInvoice();
    end;

    var
        GlobalBCPTTestContext: Codeunit "BCPT Test Context";
        IsInitialized: Boolean;
        NoOfLinesParamLbl: Label 'Lines';
        ParamValidationErr: Label 'Parameter is not defined in the correct format. The expected format is "%1"', comment = '%1 = Parameter name';
        NoOfLinesToCreate: Integer;

    local procedure InitTest();
    var
        PurchasesPayablesSetup: Record "Purchases & Payables Setup";
        NoSeriesLine: Record "No. Series Line";
        RecordModified: Boolean;
    begin
        PurchasesPayablesSetup.Get();
        PurchasesPayablesSetup.TestField("Invoice Nos.");
        if PurchasesPayablesSetup."Ext. Doc. No. Mandatory" then begin
            PurchasesPayablesSetup."Ext. Doc. No. Mandatory" := false;
            PurchasesPayablesSetup.Modify();
            RecordModified := true;
        end;

        NoSeriesLine.SetRange("Series Code", PurchasesPayablesSetup."Invoice Nos.");
        NoSeriesLine.FindSet(true);
        repeat
            if NoSeriesLine."Ending No." <> '' then begin
                NoSeriesLine."Ending No." := '';
                NoSeriesLine.Validate(Implementation, Enum::"No. Series Implementation"::Sequence);
                NoSeriesLine.Modify(true);
                RecordModified := true;
            end;
        until NoSeriesLine.Next() = 0;

        if RecordModified then
            Commit();

        if Evaluate(NoOfLinesToCreate, GlobalBCPTTestContext.GetParameter(NoOfLinesParamLbl)) then;
    end;

    procedure CreateAndPostPurchaseInvoice()
    var
        PurchaseHeader: Record "Purchase Header";
        VendorNo: Code[20];
    begin
        if NoOfLinesToCreate < 0 then
            NoOfLinesToCreate := 0;
        if NoOfLinesToCreate > 10000 then
            NoOfLinesToCreate := 10000;

        //Find a random vendor
        VendorNo := SelectRandomVendor();

        GlobalBCPTTestContext.StartScenario('Create Purchase Invoice');
        CreatePurchaseInvoiceForVendorNo(PurchaseHeader, VendorNo);
        GlobalBCPTTestContext.EndScenario('Create Purchase Invoice');

        GlobalBCPTTestContext.StartScenario('Post Purchase Invoice');
        CODEUNIT.Run(CODEUNIT::"Purch.-Post (Yes/No)", PurchaseHeader);
        GlobalBCPTTestContext.EndScenario('Post Purchase Invoice');
    end;

    local procedure SelectRandomVendor(): Code[20]
    var
        Vendor: Record Vendor;
    begin
        Vendor.SetRange(Blocked, Vendor.Blocked::" ");
        Vendor.Next(SessionId() mod Vendor.Count());
        exit(Vendor."No.");
    end;

    local procedure CreatePurchaseInvoiceForVendorNo(var PurchaseHeader: Record "Purchase Header"; VendorNo: Code[20])
    var
        PurchaseLine: Record "Purchase Line";
        i: Integer;
        LineNo: Integer;
    begin
        CreatePurchHeader(PurchaseHeader, PurchaseHeader."Document Type"::Invoice, VendorNo);
        LineNo := 1000;
        for i := 1 to NoOfLinesToCreate do begin
            CreatePurchaseLine(PurchaseLine, PurchaseHeader, LineNo);
            LineNo := LineNo + 1000;
        end;
    end;

    procedure CreatePurchHeader(var PurchaseHeader: Record "Purchase Header"; DocumentType: Enum "Purchase Document Type"; BuyfromVendorNo: Code[20])
    begin
        Clear(PurchaseHeader);
        PurchaseHeader.Validate("Document Type", DocumentType);
        PurchaseHeader.Insert(true);
        PurchaseHeader.Validate("Buy-from Vendor No.", BuyfromVendorNo);
        PurchaseHeader.Modify(true);
        Commit();
    end;

    local procedure CreatePurchaseLine(var PurchaseLine: Record "Purchase Line"; PurchaseHeader: Record "Purchase Header"; LineNo: Integer)
    begin
        PurchaseLine.Init();
        PurchaseLine.Validate("Document Type", PurchaseHeader."Document Type");
        PurchaseLine.Validate("Document No.", PurchaseHeader."No.");
        PurchaseLine.Validate("Line No.", LineNo);
        PurchaseLine.Insert(true);
        Commit();

        PurchaseLine.Validate(Type, PurchaseLine.Type::Item);
        PurchaseLine.Validate("No.", SelectRandomItem());
        PurchaseLine.Validate(Quantity, 1);
        PurchaseLine.Modify(true);
        Commit();
    end;

    local procedure SelectRandomItem(): Code[20]
    var
        Item: Record Item;
    begin
        Item.SetRange(Blocked, false);
        Item.Next(SessionId() mod Item.Count());
        exit(Item."No.");
    end;

    procedure GetDefaultParameters(): Text[1000]
    begin
        exit(copystr(NoOfLinesParamLbl + '=' + Format(10), 1, 1000));
    end;

    procedure ValidateParameters(Parameters: Text[1000])
    begin
        if StrPos(Parameters, NoOfLinesParamLbl) > 0 then begin
            Parameters := DelStr(Parameters, 1, StrLen(NoOfLinesParamLbl + '='));
            if Evaluate(NoOfLinesToCreate, Parameters) then
                exit;
        end;
        Error(ParamValidationErr, GetDefaultParameters());
    end;
}
