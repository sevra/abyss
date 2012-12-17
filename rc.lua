local ipairs = ipairs

function iter(t)
   local i = 0
   return function () i = i + 1; return t[i] end
end

function obj(mass, density, pos, vel)
   local x, y, z = unpack(pos)
   local i, j, k = unpack(vel)
   return { mass, density, x, y, z, i, j, k }
end

function init(objects)
   for object in iter(objects) do
      create(object)
   end
end

objects = {
   obj(300, 1,    { 0, 0, 0 },      { 0, 0, 0 }),
   obj(20, 1,     { 60, 0, 0 },     { 0, -2, 0 }),
   obj(.1, 1,     { 66, 0, 0 },     { .5, -3.3, 0 }),
   obj(.75, 1,    { -25, 5, 0 },    { .4, 2, 0 }),
   obj(.75, 1,    { -30, -10, 0 },  { .4, 2, -1 }),
   obj(.75, 1,    { -40, -25, 0 },  { .4, 2, 1 }),
}

init(objects)
