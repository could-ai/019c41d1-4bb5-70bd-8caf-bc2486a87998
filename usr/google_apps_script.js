// GOOGLE APPS SCRIPT CODE
// 1. Open your Google Sheet
// 2. Go to Extensions > Apps Script
// 3. Paste this code into Code.gs
// 4. Click Deploy > New Deployment > Select type: Web app
// 5. Set "Who has access" to "Anyone"
// 6. Copy the Web App URL and paste it into the Flutter app

function doPost(e) {
  try {
    // 1. Parse the incoming JSON data
    var data = JSON.parse(e.postData.contents);
    var entries = data.entries; // Expecting { "entries": [ ... ] }

    // 2. Get the active sheet
    var sheet = SpreadsheetApp.getActiveSpreadsheet().getActiveSheet();

    // 3. Add headers if the sheet is empty
    if (sheet.getLastRow() === 0) {
      sheet.appendRow(["ID", "Date", "Start Time", "End Time", "Description", "Duration (Hours)"]);
      // Optional: Make headers bold
      sheet.getRange(1, 1, 1, 6).setFontWeight("bold");
    }

    // 4. Loop through entries and append to sheet
    entries.forEach(function(entry) {
      sheet.appendRow([
        entry.id,
        entry.date,
        entry.startTime,
        entry.endTime,
        entry.description,
        entry.duration
      ]);
    });

    // 5. Return success response
    return ContentService.createTextOutput(JSON.stringify({
      "status": "success",
      "message": "Added " + entries.length + " entries."
    })).setMimeType(ContentService.MimeType.JSON);

  } catch (error) {
    // Handle errors
    return ContentService.createTextOutput(JSON.stringify({
      "status": "error",
      "message": error.toString()
    })).setMimeType(ContentService.MimeType.JSON);
  }
}

function doGet(e) {
  return ContentService.createTextOutput("This web app is active. Use POST to send data.");
}
