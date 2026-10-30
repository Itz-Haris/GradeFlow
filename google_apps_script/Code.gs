/**
 * =========================================================================
 * GradeFlow — Student Academic Records API (Google Apps Script Web App)
 * =========================================================================
 * 
 * Subject: Digital Literacy and Application (Unit 6, Activity 6)
 * Department: Robotics and Automation
 * 
 * Spreadsheet Header Structure:
 * | Sr No | Roll No | Student Name | 10th | 12th | Sem 1 | Sem 2 |
 * 
 * Instructions:
 * 1. Set SPREADSHEET_ID to your Google Sheet ID (found in your Sheet URL)
 *    OR leave empty ("") if this script is bound directly inside the Google Sheet (Extensions > Apps Script).
 * 2. Set SHEET_NAME to the exact name of your worksheet tab (e.g. "Sheet1" or "Students").
 * 3. Deploy as Web App:
 *    - Execute as: "Me"
 *    - Who has access: "Anyone"
 * 4. Copy the deployment URL into GradeFlow app.
 */

// CONFIGURATION VARIABLES (REPLACE WITH YOUR SPREADSHEET DETAILS)
var SPREADSHEET_ID = "YOUR_SPREADSHEET_ID_HERE"; // Leave empty if script is bound directly to the sheet
var SHEET_NAME = "Sheet1";

/**
 * Handles incoming HTTP GET requests from GradeFlow Flutter application.
 * Returns valid JSON containing an array of student record objects.
 */
function doGet(e) {
  try {
    var sheet = getSheetInstance();
    if (!sheet) {
      return buildJsonResponse({
        status: "error",
        message: "Worksheet '" + SHEET_NAME + "' could not be found."
      });
    }

    var data = sheet.getDataRange().getValues();
    if (data.length <= 1) {
      return buildJsonResponse({
        status: "success",
        total: 0,
        records: []
      });
    }

    // Row 1 contains column headers
    var headers = data[0].map(function(h) {
      return (h != null) ? h.toString().trim() : "";
    });

    var studentRecords = [];

    // Iterate through data rows (skipping header at row 0)
    for (var r = 1; r < data.length; r++) {
      var row = data[r];

      // Check if row is completely empty
      var isBlank = row.every(function(cell) {
        return cell === null || cell === undefined || cell.toString().trim() === "";
      });
      if (isBlank) continue;

      var record = {};
      var hasIdentifiableInfo = false;

      for (var c = 0; c < headers.length; c++) {
        var headerKey = headers[c];
        if (!headerKey) continue;

        var cellValue = row[c];

        // Format numeric / string / missing values
        if (cellValue === null || cellValue === undefined || cellValue.toString().trim() === "") {
          record[headerKey] = null; // Explicit null for missing scores
        } else if (typeof cellValue === "number") {
          record[headerKey] = cellValue;
          hasIdentifiableInfo = true;
        } else {
          var trimmedStr = cellValue.toString().trim();
          if (trimmedStr.toUpperCase() === "N/A" || trimmedStr.toUpperCase() === "NA" || trimmedStr === "-") {
            record[headerKey] = null;
          } else {
            // Check if string represents a number (e.g. "85.5")
            var numericVal = Number(trimmedStr);
            if (!isNaN(numericVal) && trimmedStr !== "") {
              record[headerKey] = numericVal;
            } else {
              record[headerKey] = trimmedStr;
            }
            hasIdentifiableInfo = true;
          }
        }
      }

      // Add only valid student records
      if (hasIdentifiableInfo) {
        studentRecords.push(record);
      }
    }

    return buildJsonResponse({
      status: "success",
      total: studentRecords.length,
      records: studentRecords
    });

  } catch (err) {
    return buildJsonResponse({
      status: "error",
      message: err.toString()
    });
  }
}

/**
 * Resolves Google Sheet reference:
 * Checks bound active spreadsheet first; if not bound, opens by SPREADSHEET_ID.
 */
function getSheetInstance() {
  var ss;
  if (SPREADSHEET_ID && SPREADSHEET_ID !== "YOUR_SPREADSHEET_ID_HERE" && SPREADSHEET_ID.trim() !== "") {
    ss = SpreadsheetApp.openById(SPREADSHEET_ID);
  } else {
    ss = SpreadsheetApp.getActiveSpreadsheet();
  }

  if (!ss) return null;
  return ss.getSheetByName(SHEET_NAME) || ss.getSheets()[0];
}

/**
 * Builds HTTP response with JSON MIME type and CORS friendly payload.
 */
function buildJsonResponse(obj) {
  var output = ContentService.createTextOutput(JSON.stringify(obj));
  output.setMimeType(ContentService.MimeType.JSON);
  return output;
}
