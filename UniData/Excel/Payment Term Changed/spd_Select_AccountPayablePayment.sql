USE [DataMart_Report]
GO

/****** Object:  StoredProcedure [dbo].[spd_Select_AccountPayablePayment]    Script Date: 2016-04-08 1:37:07 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		NESTOR JARQUIN
-- Create date: MAY 2014
-- Description:	STORED PROCEDURES FOR ACCOUNT PAYABLE REPORT (JUNTAN)
-- =============================================

ALTER PROCEDURE [dbo].[spd_Select_AccountPayablePayment]
@strFromCheckDate			VARCHAR(10)	 = NULL
,	@strToCheckDate			VARCHAR(10)  = NULL
,	@strCurrencyCode 		VARCHAR(100) = NULL
,	@strCheckNumber 		VARCHAR(100) = NULL
,	@strBankCode			VARCHAR(100) = NULL
,	@strCompanyCode 		VARCHAR(100) = NULL
,	@strSupplierCode 		VARCHAR(100) = NULL
,	@strInvoiceNumber 		VARCHAR(100) = NULL
,	@strCheckImageFileName 	VARCHAR(100) = NULL
,	@strLanguage			VARCHAR(2)   = 'FR'
AS
BEGIN
	SET NOCOUNT ON;

	IF @strLanguage = 'FR'
	BEGIN
		SELECT	CONVERT(varchar(10), AccountPayablePayment.CheckDate, 103) AS [Date du chèque]
			,	AccountPayablePayment.CurrencyCode  AS [Devise]
			,	AccountPayablePayment.CheckNumber AS [Numéro du chèque]
			,	AccountPayablePayment.BankCode AS [Code de la banque]
			,	AccountPayablePayment.CompanyCode AS [Code de la compagnie]
			,	AccountPayablePayment.SupplierCode AS [Le fournisseur]
			,	AccountPayablePaymentInvoice.InvoiceNumber AS [Numéro de facture]
			,	AccountPayablePayment.CheckImageFileName AS [Nom de fichier]
		FROM 	DataWarehouse..AccountPayablePayment AccountPayablePayment
				INNER JOIN DataWarehouse..AccountPayablePaymentInvoice AccountPayablePaymentInvoice
					ON AccountPayablePayment.CheckNumber = AccountPayablePaymentInvoice.CheckNumber
					AND AccountPayablePayment.BankCode = AccountPayablePaymentInvoice.BankCode
		WHERE	AccountPayablePayment.CheckDate BETWEEN CAST(@strFromCheckDate AS smalldatetime) AND CAST(@strToCheckDate AS smalldatetime)
			AND	AccountPayablePayment.CurrencyCode LIKE ISNULL(@strCurrencyCode , AccountPayablePayment.CurrencyCode) + '%'
			AND	AccountPayablePayment.CheckNumber LIKE ISNULL(@strCheckNumber, AccountPayablePayment.CheckNumber) + '%'
			AND	AccountPayablePayment.BankCode LIKE ISNULL(@strBankCode, AccountPayablePayment.BankCode) + '%'
			AND	AccountPayablePayment.CompanyCode LIKE ISNULL(@strCompanyCode, AccountPayablePayment.CompanyCode) + '%'
			AND	AccountPayablePayment.SupplierCode LIKE ISNULL(@strSupplierCode, AccountPayablePayment.SupplierCode) + '%'
			AND	AccountPayablePaymentInvoice.InvoiceNumber LIKE ISNULL(@strInvoiceNumber, AccountPayablePaymentInvoice.InvoiceNumber) + '%'
		ORDER BY AccountPayablePayment.CheckDate
	END
	ELSE
	BEGIN
		SELECT	CONVERT(varchar(10), AccountPayablePayment.CheckDate, 103) AS [CheckDate]
			,	AccountPayablePayment.CurrencyCode  AS [Currency]
			,	AccountPayablePayment.CheckNumber AS [CheckNumber]
			,	AccountPayablePayment.BankCode AS [BankCode]
			,	AccountPayablePayment.CompanyCode AS [CompanyCode]
			,	AccountPayablePayment.SupplierCode AS [SupplierCode]
			,	AccountPayablePaymentInvoice.InvoiceNumber AS [InvoiceNumber]
			,	AccountPayablePayment.CheckImageFileName AS [ImageFileName]
		FROM 	DataWarehouse..AccountPayablePayment AccountPayablePayment
				INNER JOIN DataWarehouse..AccountPayablePaymentInvoice AccountPayablePaymentInvoice
					ON AccountPayablePayment.CheckNumber = AccountPayablePaymentInvoice.CheckNumber
					AND AccountPayablePayment.BankCode = AccountPayablePaymentInvoice.BankCode
		WHERE	AccountPayablePayment.CheckDate BETWEEN CAST(@strFromCheckDate AS SMALLDATETIME) AND CAST(@strToCheckDate AS SMALLDATETIME)
			AND	AccountPayablePayment.CurrencyCode LIKE ISNULL(@strCurrencyCode , AccountPayablePayment.CurrencyCode) + '%'
			AND	AccountPayablePayment.CheckNumber LIKE ISNULL(@strCheckNumber, AccountPayablePayment.CheckNumber) + '%'
			AND	AccountPayablePayment.BankCode LIKE ISNULL(@strBankCode, AccountPayablePayment.BankCode) + '%'
			AND	AccountPayablePayment.CompanyCode LIKE ISNULL(@strCompanyCode, AccountPayablePayment.CompanyCode) + '%'
			AND	AccountPayablePayment.SupplierCode LIKE ISNULL(@strSupplierCode, AccountPayablePayment.SupplierCode) + '%'
			AND	AccountPayablePaymentInvoice.InvoiceNumber LIKE ISNULL(@strInvoiceNumber, AccountPayablePaymentInvoice.InvoiceNumber) + '%'
		ORDER BY AccountPayablePayment.CheckDate
	END

END

GO


