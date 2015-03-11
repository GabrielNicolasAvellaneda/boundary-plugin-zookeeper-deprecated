local framework = require('framework/framework.lua')
framework.table()
framework.util()
framework.functional()
local stringutil = framework.string

local Plugin = framework.Plugin
local DataSource = framework.DataSource
local Accumulator = framework.Accumulator
local net = require('net')
require('fun')(true) -- Shows a warn when overriding an existing function.

local params = framework.boundary.param
params.name = 'Boundary Zookeeper plugin'
params.version = '1.0'

local ZookeeperDataSource = DataSource:extend()
function ZookeeperDataSource:initialize(host, port)
	self.host = host
	self.port = port
end

function ZookeeperDataSource:fetch(context, callback)

	local socket
	socket = net.createConnection(self.port, self.host, function ()
		socket:write('mntr\n')

		if callback then
			socket:once('data', function (data)
				callback(data)
				socket:shutdown()
			end)
		else
			socket:shutdown()
		end

		end)
	socket:on('error', function (err) self:emit('error', 'Socket error: ' .. err.message) end)
end

local dataSource = ZookeeperDataSource:new(params.host, params.port)

local plugin = Plugin:new(params, dataSource)

function parseLine(line)
	local parts = stringutil.split(line, '\t')

	return parts
end

function toMapReducer (acc, x)
	local k = x[1]
	local v = x[2]

	acc[k] = v

	return acc
end

function parse(data)
	local lines = filter(stringutil.notEmpty, stringutil.split(data, '\n'))
	local parsedLines = map(parseLine, lines)
	local m = reduce(toMapReducer, {}, parsedLines)

	return m
end

local accumulated = Accumulator:new() 
function plugin:onParseValues(data)
	
	local parsed = parse(data)
		
	local metrics = {}
	
	metrics['ZK_WATCH_COUNT'] = false
	metrics['ZK_NUM_ALIVE_CONNECTIONS'] = false
	metrics['ZK_OPEN_FILE_DESCRIPTOR_COUNT'] = false
	metrics['ZK_PACKETS_SENT'] =  true
	metrics['ZK_PACKETS_RECEIVED'] = true
	metrics['ZK_MIN_LATENCY'] = false
	metrics['ZK_EPHEMERALS_COUNT'] = false
	metrics['ZK_ZNODE_COUNT'] = false
	metrics['ZK_MAX_FILE_DESCRIPTOR_COUNT'] = false

	local result = {}
	each(
		function (boundaryName, acc) 
			local metricName = string.lower(boundaryName) 
			local value = tonumber(parsed[metricName])
			if acc then
				value = accumulated:accumulate(boundaryName, value)
			end

			result[boundaryName] = value	
		end, metrics)

	return result	
end

plugin:poll()

