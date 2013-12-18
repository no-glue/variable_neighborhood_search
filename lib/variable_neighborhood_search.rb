require "variable_neighborhood_search/version"

module VariableNeighborhoodSearch
  class VariableNeighborhoodSearch
    # get distance
    def euc_2d(c1, c2)
      Math.sqrt((c1[0] - c2[0]) ** 2 + (c1[1] - c2[1]) ** 2).round
    end

    # shake
    def shake(cities)
      shake = Array.new(cities.size){|i| i}
      shake.each_index do |i|
        r = rand(shake.size - 1) + 1
        shake[i], shake[r] = shake[r], shake[i]
      end
      shake
    end

    # shake in range
    def two_opt(shake)
      sh = Array.new(shake)
      c1, c2 = rand(sh.size), rand(sh.size)
      pool = [c1]
      pool << ((c1 == 0) ? sh.size - 1 : c1 + 1)
      pool << ((c1 == (sh.size - 1)) ? 0 : c1 - 1)
      c2 = rand(sh.size) while pool.include? c2
      c1, c2 = c2, c1 if c2 < c1
      sh[c1...c2] = sh[c1...c2].reverse
      sh
    end

    # cost
    def cost(shake, cities)
      distance = 0
      shake.each_with_index do |c1, i|
        c2 = (i == (shake.size - 1)) ? shake[0] : shake[i + 1]
        c1, c2 = c2, c1 if c2 < c1
        distance += euc_2d(cities[c1], cities[c2])
      end
      distance
    end

    # local search
    def local_search(best, cities, max_no_improv, neighborhood)
      count = 0
        begin
          candidate = {:vector => shake(cities)}
          neighborhood.times(two_opt(candidate[:vector]))
          candidate[:cost] = cost(candidate[:vector], cities)
          if candidate[:cost] < best[:cost]
            count, best = 0, candidate
          else
            count += 1
        end until count >= max_no_improv
      best
    end

    # search
    def search(cities, neighborhoods, max_no_improv, max_no_improv_ls)
      best = {:vector => shake(cities), :cost => cost(best[:vector], cities)}
      iter, count = 0, 0
      begin
        neighborhoods.each do |neigh|
          candidate = {:vector => Array.new(best[:vector])}
          neigh.times(two_opt(candidate[:vector]))
          candidate[:cost] = cost(candidate[:vector], cities)
          candidate = local_search(candidate, cities, max_no_improv_ls)
          puts " > iteration #{(iter + 1)}, neigh = #{neigh}, best = #{best[:cost]}"
          iter += 1
          if candidate[:cost] < best[:cost]
            best, count = candidate, 0
            break
          else
            count += 1
          end
        end
      end until count >= max_no_improv
    end
  end
end
