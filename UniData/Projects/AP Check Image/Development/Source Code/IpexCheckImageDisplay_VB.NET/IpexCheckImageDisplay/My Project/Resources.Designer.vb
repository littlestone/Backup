﻿'------------------------------------------------------------------------------
' <auto-generated>
'     This code was generated by a tool.
'     Runtime Version:4.0.30319.18444
'
'     Changes to this file may cause incorrect behavior and will be lost if
'     the code is regenerated.
' </auto-generated>
'------------------------------------------------------------------------------

Option Strict On
Option Explicit On

Imports System

Namespace My.Resources
    
    'This class was auto-generated by the StronglyTypedResourceBuilder
    'class via a tool like ResGen or Visual Studio.
    'To add or remove a member, edit your .ResX file then rerun ResGen
    'with the /str option, or rebuild your VS project.
    '''<summary>
    '''  A strongly-typed resource class, for looking up localized strings, etc.
    '''</summary>
    <Global.System.CodeDom.Compiler.GeneratedCodeAttribute("System.Resources.Tools.StronglyTypedResourceBuilder", "4.0.0.0"),  _
     Global.System.Diagnostics.DebuggerNonUserCodeAttribute(),  _
     Global.System.Runtime.CompilerServices.CompilerGeneratedAttribute(),  _
     Global.Microsoft.VisualBasic.HideModuleNameAttribute()>  _
    Public Module Resources
        
        Private resourceMan As Global.System.Resources.ResourceManager
        
        Private resourceCulture As Global.System.Globalization.CultureInfo
        
        '''<summary>
        '''  Returns the cached ResourceManager instance used by this class.
        '''</summary>
        <Global.System.ComponentModel.EditorBrowsableAttribute(Global.System.ComponentModel.EditorBrowsableState.Advanced)>  _
        Public ReadOnly Property ResourceManager() As Global.System.Resources.ResourceManager
            Get
                If Object.ReferenceEquals(resourceMan, Nothing) Then
                    Dim temp As Global.System.Resources.ResourceManager = New Global.System.Resources.ResourceManager("IpexCheckImageDisplay.Resources", GetType(Resources).Assembly)
                    resourceMan = temp
                End If
                Return resourceMan
            End Get
        End Property
        
        '''<summary>
        '''  Overrides the current thread's CurrentUICulture property for all
        '''  resource lookups using this strongly typed resource class.
        '''</summary>
        <Global.System.ComponentModel.EditorBrowsableAttribute(Global.System.ComponentModel.EditorBrowsableState.Advanced)>  _
        Public Property Culture() As Global.System.Globalization.CultureInfo
            Get
                Return resourceCulture
            End Get
            Set
                resourceCulture = value
            End Set
        End Property
        
        '''<summary>
        '''  Looks up a localized string similar to Reset.
        '''</summary>
        Public ReadOnly Property btnReset() As String
            Get
                Return ResourceManager.GetString("btnReset", resourceCulture)
            End Get
        End Property
        
        '''<summary>
        '''  Looks up a localized string similar to Search.
        '''</summary>
        Public ReadOnly Property btnSearch() As String
            Get
                Return ResourceManager.GetString("btnSearch", resourceCulture)
            End Get
        End Property
        
        '''<summary>
        '''  Looks up a localized string similar to To Excel.
        '''</summary>
        Public ReadOnly Property btnToExcel() As String
            Get
                Return ResourceManager.GetString("btnToExcel", resourceCulture)
            End Get
        End Property
        
        '''<summary>
        '''  Looks up a localized string similar to View.
        '''</summary>
        Public ReadOnly Property btnView() As String
            Get
                Return ResourceManager.GetString("btnView", resourceCulture)
            End Get
        End Property
        
        '''<summary>
        '''  Looks up a localized string similar to CheckImage.
        '''</summary>
        Public ReadOnly Property dgvCheckImage() As String
            Get
                Return ResourceManager.GetString("dgvCheckImage", resourceCulture)
            End Get
        End Property
        
        '''<summary>
        '''  Looks up a localized string similar to Excel Workbook (*.xlsx)|*.xlsx|All files (*.*)|*.*.
        '''</summary>
        Public ReadOnly Property dlgSaveAsFilter() As String
            Get
                Return ResourceManager.GetString("dlgSaveAsFilter", resourceCulture)
            End Get
        End Property
        
        '''<summary>
        '''  Looks up a localized string similar to Excel 2003 Workbook (*.xls)|*.xls|All files (*.*)|*.*.
        '''</summary>
        Public ReadOnly Property dlgSaveAsFilter2003() As String
            Get
                Return ResourceManager.GetString("dlgSaveAsFilter2003", resourceCulture)
            End Get
        End Property
        
        '''<summary>
        '''  Looks up a localized string similar to Bank Code.
        '''</summary>
        Public ReadOnly Property lblBankCode() As String
            Get
                Return ResourceManager.GetString("lblBankCode", resourceCulture)
            End Get
        End Property
        
        '''<summary>
        '''  Looks up a localized string similar to Check Date.
        '''</summary>
        Public ReadOnly Property lblCheckDate() As String
            Get
                Return ResourceManager.GetString("lblCheckDate", resourceCulture)
            End Get
        End Property
        
        '''<summary>
        '''  Looks up a localized string similar to Check #.
        '''</summary>
        Public ReadOnly Property lblCheckNumber() As String
            Get
                Return ResourceManager.GetString("lblCheckNumber", resourceCulture)
            End Get
        End Property
        
        '''<summary>
        '''  Looks up a localized string similar to Company.
        '''</summary>
        Public ReadOnly Property lblCompanyCode() As String
            Get
                Return ResourceManager.GetString("lblCompanyCode", resourceCulture)
            End Get
        End Property
        
        '''<summary>
        '''  Looks up a localized string similar to Currency.
        '''</summary>
        Public ReadOnly Property lblCurrency() As String
            Get
                Return ResourceManager.GetString("lblCurrency", resourceCulture)
            End Get
        End Property
        
        '''<summary>
        '''  Looks up a localized string similar to Invoice #.
        '''</summary>
        Public ReadOnly Property lblInvoiceNumber() As String
            Get
                Return ResourceManager.GetString("lblInvoiceNumber", resourceCulture)
            End Get
        End Property
        
        '''<summary>
        '''  Looks up a localized string similar to Supplier.
        '''</summary>
        Public ReadOnly Property lblSupplierCode() As String
            Get
                Return ResourceManager.GetString("lblSupplierCode", resourceCulture)
            End Get
        End Property
        
        '''<summary>
        '''  Looks up a localized string similar to The date range cannot be greater than.
        '''</summary>
        Public ReadOnly Property msgCheckDateRange() As String
            Get
                Return ResourceManager.GetString("msgCheckDateRange", resourceCulture)
            End Get
        End Property
        
        '''<summary>
        '''  Looks up a localized string similar to The from date cannot be greater than the to date..
        '''</summary>
        Public ReadOnly Property msgCheckDateValidation() As String
            Get
                Return ResourceManager.GetString("msgCheckDateValidation", resourceCulture)
            End Get
        End Property
        
        '''<summary>
        '''  Looks up a localized string similar to The check image file does not exist..
        '''</summary>
        Public ReadOnly Property msgCheckImageFile() As String
            Get
                Return ResourceManager.GetString("msgCheckImageFile", resourceCulture)
            End Get
        End Property
        
        '''<summary>
        '''  Looks up a localized string similar to  days..
        '''</summary>
        Public ReadOnly Property msgDays() As String
            Get
                Return ResourceManager.GetString("msgDays", resourceCulture)
            End Get
        End Property
        
        '''<summary>
        '''  Looks up a localized string similar to Exporting to Excel, please wait....
        '''</summary>
        Public ReadOnly Property msgExportToExcel() As String
            Get
                Return ResourceManager.GetString("msgExportToExcel", resourceCulture)
            End Get
        End Property
        
        '''<summary>
        '''  Looks up a localized string similar to No check record(s) found to export..
        '''</summary>
        Public ReadOnly Property msgNoRecord() As String
            Get
                Return ResourceManager.GetString("msgNoRecord", resourceCulture)
            End Get
        End Property
        
        '''<summary>
        '''  Looks up a localized string similar to Launching windows open file dialog box, please wait....
        '''</summary>
        Public ReadOnly Property msgSaveAsDialogBox() As String
            Get
                Return ResourceManager.GetString("msgSaveAsDialogBox", resourceCulture)
            End Get
        End Property
        
        '''<summary>
        '''  Looks up a localized string similar to  check record(s) found..
        '''</summary>
        Public ReadOnly Property stbResult() As String
            Get
                Return ResourceManager.GetString("stbResult", resourceCulture)
            End Get
        End Property
        
        '''<summary>
        '''  Looks up a localized string similar to Enter selection criteria to seach....
        '''</summary>
        Public ReadOnly Property stbSearch() As String
            Get
                Return ResourceManager.GetString("stbSearch", resourceCulture)
            End Get
        End Property
        
        '''<summary>
        '''  Looks up a localized string similar to Searching, please wait....
        '''</summary>
        Public ReadOnly Property stbWait() As String
            Get
                Return ResourceManager.GetString("stbWait", resourceCulture)
            End Get
        End Property
        
        '''<summary>
        '''  Looks up a localized string similar to APChequeImageSearchResult_.
        '''</summary>
        Public ReadOnly Property strExcelFileName() As String
            Get
                Return ResourceManager.GetString("strExcelFileName", resourceCulture)
            End Get
        End Property
        
        '''<summary>
        '''  Looks up a localized string similar to Result.
        '''</summary>
        Public ReadOnly Property tabResult() As String
            Get
                Return ResourceManager.GetString("tabResult", resourceCulture)
            End Get
        End Property
        
        '''<summary>
        '''  Looks up a localized string similar to Search.
        '''</summary>
        Public ReadOnly Property tabSearch() As String
            Get
                Return ResourceManager.GetString("tabSearch", resourceCulture)
            End Get
        End Property
        
        '''<summary>
        '''  Looks up a localized string similar to AP Check Image Inquiry v1.0.
        '''</summary>
        Public ReadOnly Property Title() As String
            Get
                Return ResourceManager.GetString("Title", resourceCulture)
            End Get
        End Property
        
        '''<summary>
        '''  Looks up a localized string similar to From Date.
        '''</summary>
        Public ReadOnly Property ttFromCheckDate() As String
            Get
                Return ResourceManager.GetString("ttFromCheckDate", resourceCulture)
            End Get
        End Property
        
        '''<summary>
        '''  Looks up a localized string similar to To Date.
        '''</summary>
        Public ReadOnly Property ttToCheckDate() As String
            Get
                Return ResourceManager.GetString("ttToCheckDate", resourceCulture)
            End Get
        End Property
    End Module
End Namespace
