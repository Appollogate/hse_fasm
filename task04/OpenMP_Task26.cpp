#include <omp.h>
#include <iostream>
#include <random>
#include <string>
#include <chrono>
#include <iomanip>
using namespace std::chrono;

// Глобальная переменная, отвечающая за факт того, было ли найдено сокровище.
bool hasFoundTreasure = false;
// Глобальная переменная, обозначающая часть острова, на которой спрятано сокровище.
int treasureLocation;
// Счётчики времени для обозначения начала и конца промежутка времени работы конкретного потока
steady_clock::time_point begin;
steady_clock::time_point end;
// Лок на вывод в консоль - чтобы два потока не выводили разные сообщения одновременно
omp_lock_t write_lock;

// Рекурсивная функция, необходимая для "задержки" потока - имитирует поиск сокровища на определённой части острова.
int DiggingForTreasure(int n) {
	if (n == 0 || n == 1)
		return 1;
	else
		return DiggingForTreasure(n - 1) + DiggingForTreasure(n - 2);
}

// Ввыводит в консоль время, прошедшее с момента запуска параллельной секции программы.
void GetElapsedTime() {
	end = steady_clock::now();
	std::cout << "Time: " << std::to_string(duration_cast<seconds>(end - begin).count()) << ":";
	std::cout << std::setfill('0') << std::setw(3) << duration_cast<milliseconds>(end - begin).count() % 1000 << " ";
}

void LookForTreasure(int team_number, int location_number) {

#pragma omp critical(StartSearching)
	{
		omp_set_lock(&write_lock);
		GetElapsedTime();
		std::cout << "Pirate " << team_number << " started location " << location_number << std::endl;
		omp_unset_lock(&write_lock);
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

	// Поиски завершились - осталось проверить, на этой ли части острова был зарыт клад.
#pragma omp critical(EndSearch)
	{
		if (location_number == treasureLocation)
		{
			hasFoundTreasure = true;
			omp_set_lock(&write_lock);
			GetElapsedTime();
			std::cout << "Pirate " << team_number << " - location " << location_number << " - FOUND!" << std::endl;
			omp_unset_lock(&write_lock);
		}
		else {
			omp_set_lock(&write_lock);
			GetElapsedTime();
			std::cout << "Pirate " << team_number << " - location " << location_number << " - not found." << std::endl;
			omp_unset_lock(&write_lock);
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
	// Инициализируем лок
	omp_init_lock(&write_lock);

	// Устанавливаем случайную часть острова, на которой спрятано сокровище.
	std::random_device randomizer;
	std::mt19937 generator(randomizer());
	std::uniform_int_distribution<int> location_distributor(1, island_parts);
	treasureLocation = location_distributor(generator);

	// Запускаем таймер
	begin = steady_clock::now();

	// Данная конструкция порождает нужное количество параллельных потоков
	// и иднамически их распределяет.
#pragma omp parallel for schedule(dynamic)
	// Цикл по количеству частей острова
	for (int i = 0; i < island_parts; i++)
	{
		if (!hasFoundTreasure) {
			// Команда с таким же номером, как у потока отправляется 
			// искать сокровища на локации с номером i+1
			LookForTreasure(omp_get_thread_num(), i + 1);
		}
	}
	// Избавляемся от лока по завершении программы
	omp_destroy_lock(&write_lock);
}

