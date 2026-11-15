-- WORKSTATION NOCTURNE V2 - Interactive calendar, Lua 5.1
local monthNames = {
  'ENERO','FEBRERO','MARZO','ABRIL','MAYO','JUNIO',
  'JULIO','AGOSTO','SEPTIEMBRE','OCTUBRE','NOVIEMBRE','DICIEMBRE'
}
local y, m
function Initialize()
  local t=os.date('*t'); y=t.year; m=t.month
end
local function render()
  SKIN:Bang('!UpdateMeasure','MeasureCalendar')
  SKIN:Bang('!UpdateMeter','CalendarTitle')
  SKIN:Bang('!UpdateMeter','CalendarGrid')
  SKIN:Bang('!Redraw')
end
function ChangeMonth(d)
  d=tonumber(d) or 0
  local t=os.date('*t', os.time{year=y,month=m+d,day=1,hour=12})
  y=t.year;m=t.month; render()
end
function ResetMonth()
  local t=os.date('*t'); y=t.year;m=t.month; render()
end
function Update()
  if not y or not m then Initialize() end
  local heading=monthNames[m]..' '..y
  SKIN:Bang('!SetVariable','CalendarTitleText',heading)
  local first=os.time{year=y,month=m,day=1,hour=12}
  local offset=(tonumber(os.date('%w',first))+6)%7
  local count=os.date('*t',os.time{year=y,month=m+1,day=0,hour=12}).day
  local lines={'LU MA MI JU VI SA DO'}
  for week=0,5 do
    local cells={}
    for weekday=0,6 do
      local day=week*7+weekday-offset+1
      if day>=1 and day<=count then
        cells[#cells+1]=string.format('%2d',day)
      else cells[#cells+1]='  ' end
    end
    lines[#lines+1]=table.concat(cells,' ')
  end
  return table.concat(lines,'\n')
end
