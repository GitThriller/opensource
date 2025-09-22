$filePath = Get-ChildItem '' -Filter *.xlsx 

foreach ($inFile in $filePath)
{
    $OutFile= $InFile.FullName.replace($InFile.Extension,'')
    $Excel = new-object -ComObject 'Excel.Application'
    $Excel.DisplayAlerts = $True
    $Excel.Visible = $False
    $WorkBook = $Excel.Workbooks.Open($InFile.FullName)

        foreach ($Worksheet in $Workbook.Worksheets)
        {
            $Worksheet.Activate()
            $Worksheet.SaveAs($OutFile+ '_' + $Worksheet.Name + '.csv', 6)
        }

    $WorkBook.Close($True)
    $Excel.Quit()
    [void][System.Runtime.Interopservices.Marshal]::ReleaseComObject($Excel)
}