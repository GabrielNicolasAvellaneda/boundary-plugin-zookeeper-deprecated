local framework = require('framework/framework.lua')
local Plugin = framework.Plugin
local NetPlugin = framework.NetPlugin
local DataSource = framework.DataSource
local net = require('net')
local lib = require('lib')
require('fun')()

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
			client:once('data', function (data)
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
	local parts = string.split(line, '\t')

	return parts
end

function toMapReducer (acc, x)
	local k = x[1]
	local v = x[2]

	acc[k] = v

	return acc
end

function notEmpty(str)
	return not string.isEmpty(str)
end

function parse(data)
	local lines = filter(notEmpty, string.split(data, '\n'))

	local parsedLines = map(parseLine, lines)
	local m = reduce(toMapReducer, {}, parsedLines)

	return m
end

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
		function (boundaryName, accumulate) 
			local metricName = string.lower(boundaryName) 

			result[boundaryName] = tonumber(parsed[metricName])
	
		end, metrics)

	return result	
end

plugin:poll()

