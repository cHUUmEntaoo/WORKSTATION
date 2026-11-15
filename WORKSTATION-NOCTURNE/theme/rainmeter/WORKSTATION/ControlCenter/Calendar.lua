
-- ================================================
-- WORKSTATION NOCTURNE - CALENDAR V1.1
-- Interactive monthly navigation
-- ================================================

local viewYear
local viewMonth

local monthNames = {
    "ENERO",
    "FEBRERO",
    "MARZO",
    "ABRIL",
    "MAYO",
    "JUNIO",
    "JULIO",
    "AGOSTO",
    "SEPTIEMBRE",
    "OCTUBRE",
    "NOVIEMBRE",
    "DICIEMBRE"
}

-- ================================================
-- INITIALIZE CALENDAR
-- ================================================

function Initialize()
    local today = os.date("*t")

    viewYear = today.year
    viewMonth = today.month
end

-- ================================================
-- REFRESH CALENDAR UI
-- ================================================

local function refreshCalendar()
    SKIN:Bang("!UpdateMeasure", "MeasureCalendar")
    SKIN:Bang("!UpdateMeter", "CalendarTitle")
    SKIN:Bang("!UpdateMeter", "CalendarGrid")
    SKIN:Bang("!Redraw")
end

-- ================================================
-- CHANGE MONTH
-- ================================================

function ChangeMonth(direction)
    direction = tonumber(direction) or 0

    viewMonth = viewMonth + direction

    while viewMonth > 12 do
        viewMonth = viewMonth - 12
        viewYear = viewYear + 1
    end

    while viewMonth < 1 do
        viewMonth = viewMonth + 12
        viewYear = viewYear - 1
    end

    refreshCalendar()
end

-- ================================================
-- RETURN TO CURRENT MONTH
-- ================================================

function ResetMonth()
    local today = os.date("*t")

    viewYear = today.year
    viewMonth = today.month

    refreshCalendar()
end

-- ================================================
-- DAYS IN MONTH
-- ================================================

local function daysInMonth(year, month)
    local lastDay = os.time({
        year = year,
        month = month + 1,
        day = 0,
        hour = 12
    })

    return os.date("*t", lastDay).day
end

-- ================================================
-- UPDATE CALENDAR DISPLAY
-- ================================================

function Update()
    if not viewYear or not viewMonth then
        Initialize()
    end

    local title = string.format(
        "%s %d",
        monthNames[viewMonth],
        viewYear
    )

    SKIN:Bang(
        "!SetVariable",
        "CalendarTitleText",
        title
    )

    local firstDay = os.time({
        year = viewYear,
        month = viewMonth,
        day = 1,
        hour = 12
    })

    -- Convert Sunday=0 to Monday=0.
    local offset =
        (tonumber(os.date("%w", firstDay)) + 6) % 7

    local count = daysInMonth(viewYear, viewMonth)

    local lines = {
        "LU MA MI JU VI SA DO"
    }

    for week = 0, 5 do
        local cells = {}

        for weekday = 0, 6 do
            local day = week * 7 + weekday - offset + 1

            if day >= 1 and day <= count then
                table.insert(
                    cells,
                    string.format("%2d", day)
                )
            else
                table.insert(cells, "  ")
            end
        end

        table.insert(
            lines,
            table.concat(cells, " ")
        )
    end

    return table.concat(lines, "\n")
end
