#include <omp.h>
#include <iostream>
#include <random>
#include <string>

// Рекурсивная функция, необходимая для "задержки" потока - имитирует поиск сокровища на определённой части острова.
int DiggingForTreasure(int n) {
	if (n == 0 || n == 1)
		return 1;
	else
		return DiggingForTreasure(n - 1) + DiggingForTreasure(n - 2);
}

void LookForTreasure(int team_number, int location_number) {
#pragma omp critical
	{
		std::cout << "Pirate team " << team_number << " started searching location " << location_number << std::endl;
	}
	// Число, подающееся на вход функции DiggingForTreasure, описанной выше.
	// Генерируется случайно в диапазоне [34, 39], обеспечивая задержку
	// выполнения потока. На собственном ПК в зависимости от параметра n
	// задержка составляла от 0,5 до 4,9 секунд.
	int n;
	std::random_device randomizer;
	std::mt19937 generator(randomizer());
	std::uniform_int_distribution<int> sleep_distributor(34, 39);
	n = sleep_distributor(generator);
	DiggingForTreasure(n);

	// Число, используемое для определения того, нашли ли пираты сокровище или нет.
	int success;
	std::uniform_int_distribution<int> success_distributor(0, 30);
	success = success_distributor(generator);

#pragma omp critical
	{
		// Генератор случайных чисел задаёт вероятность "найти сокровище".
		// Сокровище найдено, если случайное число от 0 до 30 превысило 15.
		if (success >= 15)
		{
			std::cout << "Pirate team " << team_number << " found the treasure on location " << location_number << "!" << std::endl;
		}
		else {
			std::cout << "Pirate team " << team_number << " found nothing on location " << location_number << "..." << std::endl;
		}
	}

}


int main(int argc, char* argv[])
{
	// Проверка на количество аргументов командной строки
	if (argc != 3) {
		std::cout << "\nWrong input format. \nEnter number of teams first, then the number of island locations to explore.\n";
		std::cout << "Correct format: exe_file_name team_count island_parts" << std::endl;
		return 1;
	}
	// Количество групп пиратов (соответственно, количество потоков). От 1 до 500.
	int pirate_team_count;
	// Количество частей, на которые Сильвер разделил остров. От 1 до 500.
	int island_parts;
	// Проверка на корректность ввода
	try {
		pirate_team_count = std::stoi(argv[1]);
		island_parts = std::stoi(argv[2]);
	}
	catch (const std::invalid_argument& e) {
		std::cout << "\nWrong input format. Please enter two positive integer numbers in range [1, 499].\n";
		std::cout << "Correct format: exe_file_name team_count island_parts" << std::endl;
		return 1;
	}
	catch (const std::out_of_range& e) {
		std::cout << "\nArgument is out of Integer range. Please try again.\n";
		std::cout << "Correct format: exe_file_name team_count island_parts" << std::endl;
		return 1;
	}
	// Проверка на положительность
	if (pirate_team_count <= 0 || island_parts <= 0 || pirate_team_count >= 500 || island_parts >= 500) {
		std::cout << "\nWrong input format. Both numbers must be in range [1, 499].\n";
		std::cout << "Correct format: exe_file_name team_count island_parts" << std::endl;
		return 1;
	}
	// Устанавливаем количество потоков, равное количеству команд пиратов
	omp_set_num_threads(pirate_team_count);

#pragma omp parallel for schedule(dynamic)
	// Цикл по количеству частей острова
	for (int i = 0; i < island_parts; i++)
	{
		LookForTreasure(omp_get_thread_num(), i + 1);
	}

}

