function value(id) {
  text = document.getElementById(id).value;
  val = parseFloat(text);
  if (val == NaN) return 0;
  return val;
}
function getInputData() {
  data = {
    targetF: value("target-f"),
    maxAggSize: value("max-agg-size"),
    averageSlump: value("avg-slump"),
    grading: value("grading"),
    aggSpg: value("avg-spg"),
    cementType: parseInt(
      document.getElementById("ctype").selectedOptions[0].getAttribute("data")
    ),
    crushedCoarseAgg:
      document
        .getElementById("crushed")
        .selectedOptions[0].getAttribute("data") == "Crushed"
  };
  return data;
}
function updateCalculation() {
  var data = getInputData();
  $.ajax({
    url: "/api/compute",
    type: "POST",
    data: JSON.stringify(data),
    contentType: "application/json",
    dataType: "json",
    success: function(result) {
      showData(result);
    }
  });
}

function showData(data) {
  table = "<table>";
  for (d in data) {
    table += "<tr><td>" + d + "</td><td>" + data[d] + "</td></tr>";
  }
  table += "</table>";
  document.getElementById("output").innerHTML = table;
}
