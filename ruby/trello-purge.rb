#!/usr/bin/ruby

require 'trello'
require 'securerandom'

def usage
	puts "Usage: trello-purge.rb %apikey% %authtoken% [%boardid%]"
	puts "If boardid is missing, prints all boards"
	puts "If boardid is set to all, purges all boards"
	puts "If boardid is set to a specific value, purges selected board"
	puts "When board is purged, every archived card is deleted"
	puts "Archived lists and boards have their content deleted and names mangled"
	exit 0
end

def purgeBoard(board)
	puts "Board: #{board.id} - #{board.name}"
	puts "Lists: "
	
	board.lists(:filter=>:all).map.each do |list|
		puts "* #{list.name}"
		list.cards(:filter=>:all).map.each do |card|
			if card.closed? || list.closed? || board.closed? then
				puts "*** Deleting card: #{card.name}"
				card.delete
			end
		end
		
		if list.closed? || board.closed? then
			puts "** Mangling list's name"
			list.close!
			list.name = SecureRandom.hex
			list.save
		end
	end

	if board.closed then
		puts "This board is closed, mangling it's name"
		board.name = SecureRandom.hex
		board.save
	end
end

def purgeAllBoards
	Trello::Board.all.each do |board|
		puts "------------------------"
		purgeBoard(board)
		puts "------------------------"
	end
end

def listAllBoards
	puts "Board list:"
	Trello::Board.all.each do |board|
		puts "#{board.id} #{board.name}"
	end
end

ARGV[1] == nil ? usage : nil

Trello.configure do |config|
	config.developer_public_key = ARGV[0]
	config.member_token = ARGV[1]
end

if ARGV[2] != nil then
	purgeBoard(Trello::Board.find(ARGV[2]))
elsif ARGV[2] == "all" then
	purgeAllBoards
else
	listAllBoards
end

