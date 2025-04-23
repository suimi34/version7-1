

export default function Stores(props: { stores: [] }) {
  return (
    <div className="grid grid-rows-[20px_1fr_20px] items-center justify-items-center min-h-screen p-8 pb-20 gap-16 sm:p-20 font-[family-name:var(--font-geist-sans)]">
      <main className="flex flex-col gap-[32px] row-start-2 items-center sm:items-start">
        <h1 className="text-3xl font-bold">Stores</h1>
        <p className="text-sm/6 text-center sm:text-left font-[family-name:var(--font-geist-mono)]">
          This is the stores page.
        </p>
        {props.stores.length > 0 ? (
          <ul className="list-inside list-decimal text-sm/6 text-center sm:text-left font-[family-name:var(--font-geist-mono)]">
            {props.stores.map((store: any) => (
              <li key={store.id} className="mb-2 tracking-[-.01em]">
                {store.name}
              </li>
            ))}
          </ul>
        ) : (
          <p className="text-sm/6 text-center sm:text-left font-[family-name:var(--font-geist-mono)]">
            No stores found.
          </p>
        )}
      </main>
    </div>
  );
}
