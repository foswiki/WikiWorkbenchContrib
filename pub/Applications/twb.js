function wikify(sourceId, targetId, suffix) {

  var source = document.getElementById(sourceId);
  var target = document.getElementById(targetId);
  if (!source || !target) {
    return;
  }
  target.value = wikifyString(source.value, suffix);
}

function wikifyString(value, suffix) {
  value = value.replace(/�/g, "ae");
  value = value.replace(/�/g, "oe");
  value = value.replace(/�/g, "ue");
  value = value.replace(/�/g, "Ae");
  value = value.replace(/�/g, "Oe");
  value = value.replace(/�/g, "Ue");
  value = value.replace(/�/g, "ss");
  value = value.replace(/[a-zA-Z\d]+/g, function(a) {
      return a.charAt(0).toLocaleUpperCase() + a.substr(1);
  });
  value = value.replace(/[^a-zA-Z\d]/g, "");
  value = value.replace(/\s/g, "");
  if (suffix) {
    value += suffix;
  }
  return value;
}
