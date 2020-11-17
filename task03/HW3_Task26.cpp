/*
Домашнее задание №3.
Практические приёмы построения многопоточных приложений.
Вариант №26.
Скрыпина Дарья Кирилловна БПИ198
*/

/*Вторая задача об Острове Сокровищ. Шайка пиратов под
предводительством Джона Сильвера высадилась на берег Острова Сокровищ.
Не смотря на добытую карту старого Флинта, местоположение сокровищ по-
прежнему остается загадкой, поэтому искать клад приходится практически
на ощупь. Так как Сильвер ходит на деревянной ноге, то самому бродить по
джунглям ему не с руки. Джон Сильвер поделил остров на участки, а пиратов
на небольшие группы. Каждой группе поручается искать клад на нескольких
участках, а сам Сильвер ждет на берегу. Группа пиратов, обшарив одну часть
острова, переходит к другой, еще необследованной части. Закончив поиски,
пираты возвращаются к Сильверу и докладывают о результатах. Требуется
создать многопоточное приложение с управляющим потоком, моделирующее
действия Сильвера и пиратов. При решении использовать парадигму
портфеля задач.*/
#include <iostream>
#include <thread>
#include <chrono>
#include <mutex>
#include <vector>
#include <string>
#include <random>

// Мьютекс на изменение счётчика кол-ва исследованных частей острова
std::mutex island;
// Мьютекс на доступ к выходному текстовому потоку в консоль, чтобы сообщения пиратов не мешались друг с другом
std::mutex callout;

// Портфель задач - переменная, в которой хранится количество исследованных частей острова
int locations_explored = 0;
// Общее количество частей острова
int locations_count;
int teams_count;

/// <summary>
/// Группа пиратов ищет клад на своём участке острова и докладывает о результатах.
/// </summary>
/// <param name="team_number">Номер группы пиратов.</param>
void LookForTreasure(int team_number) {
	while (1) {
		// Команда пиратов выбирает следующую необследованную часть острова.
		// Закрытие мьютекса на количество исследованных частей островов.
		island.lock();
		int location_tag = locations_explored;
		// Если номер части острова (нумеруются с 1) больше или равен количеству
		// обследованных частей, то копать больше не надо - выходим из метода
		if (location_tag >= locations_count) {
			island.unlock();
			return;
		}
		// Увеличение счётчика исследованных локаций на 1
		++locations_explored;
		// Открытие мьютекса на количество исследованных частей островов.
		island.unlock();

		// Генераторы случайных чисел - для времени копания сокровищ и для определения нахождения сокровищ
		std::random_device randomizer;
		std::mt19937 generator(randomizer());
		std::uniform_int_distribution<int> distributor_digging(0, 4);
		std::uniform_int_distribution<int> distributor_treasure(0, 25);

		// Пираты достают свои лопаты и начинают копать...
		std::this_thread::sleep_for(std::chrono::seconds(distributor_digging(generator)));

		// Пираты раскапывают сокровище! Или не раскапывают?
		bool foundTreasure = distributor_treasure(generator) >= 15;
		// Закрытие мьютекса на вывод в консоль
		callout.lock();
		if (foundTreasure) {
			// Вывод сообщения об успехе с номером команды и части острова
			std::cout << "Ahoy, captain! Team " << team_number << " found a treasure! Location " << location_tag + 1 << ", yarr!" << std::endl;
		}
		else {
			// Вывод сообщения о неудаче с номером команды и части острова
			std::cout << "Team " << team_number << " found no treasure, captain! Location " << location_tag + 1 << " is empty..." << std::endl;
		}
		// Открытие мьютекса на вывод в консоль
		callout.unlock();
	}
}

int main(int argc, char* argv[]) { 

	// Проверка на количество аргументов командной строки
	if (argc != 3) {
		std::cout << "\nWrong input format. \nEnter number of teams first, then the number of island parts.\n";
		return 1;
	}

	// Проверка на то, что введённые аргументы являются целыми числами типа int
	try {
		teams_count = std::stoi(argv[1]);
		locations_count = std::stoi(argv[2]);
	}
	catch (std::invalid_argument&) {
		std::cout << "\nWrong input format. Please enter two positive integer numbers in range (0, 1000).\n";
		return 1;
	}
	catch (std::out_of_range&) {
		std::cout << "\nArgument is out of Integer range. Please try again.\n";
		return 1;
	}

	// Проверка на положительность
	if (teams_count <= 0 || locations_count <= 0) {
		std::cout << "\nWrong input format. Both numbers must be more than 0 and less than 1000.\n";
		return 1;
	}

	// Проверка на слишком большое количество потоков
	if (teams_count >= 1000) {
		std::cout << "\nToo many pirate teams (threads)! Silver's ship can't handle that many pirates." << 
			"\nPlease try again. Number of teams must be more than 0 and less than 1000.\n";
		return 1;
	}

	// Создаём вектор, который будет хранить потоки.
	std::vector<std::thread> teams;
	// Капитан Джон Сильвер отправляет пиратов на поиски сокровищ...
	for (int i = 1; i <= teams_count; i++)
	{
		teams.push_back(std::thread(LookForTreasure, i));
	}

	// Ожидаем завершения работы потоков пиратов
	for (int i = 0; i < teams_count; i++)
	{
		teams[i].join();
	}
}
