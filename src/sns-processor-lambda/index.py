import xlrd
import xlwt
import json
import os.path
import datetime
# import boto3
# import requests

def getColNames(sheet):
	rowSize = sheet.row_len(0)
	colValues = sheet.row_values(0, 0, rowSize )
	columnNames = []

	for value in colValues:
		columnNames.append(value)

	return columnNames

def getRowData(row, columnNames):
	rowData = {}
	counter = 0

	for cell in row:
		# check if it is of date type print in iso format
		if cell.ctype==xlrd.XL_CELL_DATE:
			rowData[columnNames[counter].lower().replace(' ', '_')] = datetime.datetime(*xlrd.xldate_as_tuple(cell.value,0)).isoformat()
		else:
			rowData[columnNames[counter].lower().replace(' ', '_')] = cell.value
		counter +=1

	return rowData

def getSheetData(sheet, columnNames):
	nRows = sheet.nrows
	sheetData = []
	counter = 1

	for idx in range(1, nRows):
		row = sheet.row(idx)
		rowData = getRowData(row, columnNames)
		sheetData.append(rowData)

	return sheetData

def getWorkBookData(workbook):
	nsheets = workbook.nsheets
	counter = 0
	workbookdata = {}

	for idx in range(0, nsheets):
		worksheet = workbook.sheet_by_index(idx)
		columnNames = getColNames(worksheet)
		sheetdata = getSheetData(worksheet, columnNames)
		workbookdata[worksheet.name.lower().replace(' ', '_')] = sheetdata

	return workbookdata

def handler(event, context):
	filename = input("Enter the path to the filename -> ")
	if os.path.isfile(filename):
		workbook = xlrd.open_workbook(filename)
		workbookdata = getWorkBookData(workbook)
		output = \
		open((filename.replace("xlsx", "json")).replace("xls", "json"), "w+")
		output.write(json.dumps(workbookdata, sort_keys=True, indent=2,  separators=(',', ": ")))
		output.close()
		print ("%s was created" %output.name)
	else:
		print ("Sorry, that was not a valid filename")
