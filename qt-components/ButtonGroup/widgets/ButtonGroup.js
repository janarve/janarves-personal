
var functionArray = null;

function init()
{
    functionArray = [];
}

// is executed in the scope of the toggled checkable
function toggled()
{
    if (this.checkItem.checked) {
        for (var i = 0; i < functionArray.length; ++i) {
            var item = functionArray[i].checkItem;
            if (item != this.checkItem) {
                item.checked = false;
            }
        }
    }
}

function Entry(checkable) {
    this.checkItem = checkable;
    this.fnToggled = toggled;
}

function addItem(checkable) {
    var entry = new Entry(checkable);
    checkable.checkedChanged.connect(entry, entry.fnToggled);
    functionArray.push(entry);
}
