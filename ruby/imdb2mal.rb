#!/usr/bin/ruby

# Simple import of IMDB csv dump to MAL
# This script doesn't work very well for two reasons:
# - MAL search API is unreliable, e.g. Mononoke-hime gives 0 results
# - IMDB uses hepburn romanji, MAL uses *-shiki romanji
# So far I've managed to import maybe only 50% out of 70 titles

require 'csv'
require 'myanimelist'
require 'uri'

MyAnimeList.configure do |config|
    config.username = ENV['USER']
    config.password = ENV['PASS']
end

MyAnimeList.verify_credentials
puts "Credentials fine"

found = 0
not_found = 0

CSV.foreach("Anime.csv", headers: true) do |row|
	title = row['Title']
	
	begin
		animes = MyAnimeList.search_anime(title)
	rescue MyAnimeList::ApiException => e
		puts "- NOT FOUND: Search error #{e} for title #{title}. IMDB URL: #{row['URL']}"
		not_found = not_found + 1
		next
	end
	
	unless animes.is_a?(Hash)
		anime = animes.first
	else
		anime = animes
	end
	
	unless anime.nil?
		found = found + 1
		mal_title = anime['title']
		rating = row['You rated'].to_i
		
		unless anime['score'].nil?
			mal_score = anime['score'].to_i
		else
			mal_score = 0
		end

		puts "Anime \"#{title}\" found as \"#{mal_title}\". Your rating: #{rating}. MAL avg. rating: #{mal_score}"
		begin
			MyAnimeList::Anime.add(anime['id'], { status: 2, score: rating })
			puts "+ Title added"
		rescue MyAnimeList::ApiException => e
			puts "Error: #{e}"
			MyAnimeList::Anime.update(anime['id'], { status: 2, score: rating })
			puts "+ Title updated"
		end
	else
		not_found = not_found + 1
		puts "- NOT FOUND: Anime \"#{title}\" not found. IMDB URL: #{row['URL']}"
	end
	sleep 1
end

puts "Found: #{found} | Not found: #{not_found}"
